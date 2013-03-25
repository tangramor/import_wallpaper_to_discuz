#!/bin/bash

LIST=/tmp/list.txt
TEMP=/tmp/tmp.txt
TEMP2=/tmp/tmp2.txt
CONTENT=/tmp/content.txt
SQLFILE=~/wallpaper.sql

# ===============存储过程===============
#DELIMITER $$

#DROP FUNCTION IF EXISTS `strSplit`$$

#CREATE 

#FUNCTION `strSplit`(
	#x varchar(255) CHARACTER SET utf8, 
	#delim varchar(12) CHARACTER SET utf8, 
	#pos int) 
	
	#RETURNS varchar(255) CHARSET utf8
	
#DETERMINISTIC

#BEGIN
   #RETURN replace(substring(substring_index(x, delim, pos), 
      #char_length(substring_index(x, delim, pos - 1)) + 1), delim, '');
	
#-- end the stored function code block
#END$$

#------------------------------------------------------------------------

#DELIMITER $$

#DROP PROCEDURE IF EXISTS `insert_wallpaper`$$

#CREATE PROCEDURE `insert_wallpaper`(
	#catid int(10),
	#uname varchar(100) CHARACTER SET utf8, 
	#uid int(10),
	#dateline int(10),
	#folder_name varchar(100) CHARACTER SET utf8, 
	#thumb varchar(100) CHARACTER SET utf8, 
	#file_list varchar(1000) CHARACTER SET utf8,
	#list_size int,
	#content text)
#BEGIN 
	#DECLARE aid BIGINT UNSIGNED;
	#DECLARE counter INT DEFAULT 0;
	#DECLARE pic VARCHAR(255) CHARACTER SET utf8;
	#DECLARE pic_name VARCHAR(100) CHARACTER SET utf8;
	#DECLARE pic_size VARCHAR(20);

	#INSERT INTO `alibbs_portal_article_title` (`catid`, `bid`, `uid`, `username`, `title`, `shorttitle`, `highlight`, `author`, `from`, `fromurl`, `url`, `summary`, `pic`, `thumb`, `remote`, `id`, `idtype`, `contents`, `allowcomment`, `owncomment`, `click1`, `click2`, `click3`, `click4`, `click5`, `click6`, `click7`, `click8`, `tag`, `dateline`, `status`, `showinnernav`) VALUES (catid, 0, 1, uname, folder_name, '', '|||', '', '', '', '', '', CONCAT('portal/wallpaper/thumbs/', thumb), 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, dateline, 0, 0);
	
	#SET aid = last_insert_id();
	
	
	#simple_loop: LOOP
		#SET counter = counter + 1;
		
		#SELECT strSplit(file_list, '|', counter) INTO pic;
		#SELECT strSplit(pic, ':', 1) INTO pic_name;
		#SELECT strSplit(pic, ':', 2) INTO pic_size;
		#INSERT INTO `alibbs_portal_attachment` (`uid`, `dateline`, `filename`, `filetype`, `filesize`, `attachment`, `isimage`, `thumb`, `remote`, `aid`) VALUES (uid, dateline, pic_name, 'jpg', CAST(pic_size AS UNSIGNED), CONCAT('wallpaper/', folder_name, '/', pic_name), 1, 1, 0, aid);
		
		#IF counter = list_size THEN
			#-- break out since we have done parsing
			#LEAVE simple_loop;
		#END IF;
	#END LOOP simple_loop;
	
	#INSERT INTO `alibbs_portal_article_content` (`aid`, `id`, `idtype`, `title`, `content`, `pageorder`, `dateline`) VALUES (aid, 0, '', '', content, 1, dateline);
#END$$
# ===============存储过程===============

WORKDIR=`pwd`
cd $WORKDIR

# 一点清理工作
rm -rf thumbs
rm -f $SQLFILE

# 列出所有文件夹
ls > $LIST

# 创建缩略图文件夹
mkdir thumbs

while read -r line
do
	cd "$WORKDIR/$line"
	
	rm -f thumb.*
	
	echo '<div><center>' > $CONTENT
	
	# 将图片文件名导入临时文件，按文件从大到小排序
	ls -S *.jpg > $TEMP
	
	# 用第一个图片生成缩略图
	read file1 < $TEMP
	thumb="thumb.$file1"
	if [ ! -f "$WORKDIR/thumbs/$thumb" ]; then
		convert -thumbnail 300x225 "$file1" "$WORKDIR/thumbs/$thumb"
	fi
		
	pic_list=""
	while read pic; do
		# 拼凑 图片1名:图片1大小|图片2名:图片2大小 字符串
		pic_list="${pic}:"$( stat -c %s "${pic}" )"|"$pic_list
		# 取得图片长宽。由于文件名空格的问题，这个处理只能保证文件名含有1个空格不出错
		imgsize=$( identify "$pic" > $TEMP2 && gawk '{print $4}' $TEMP2 | sed "s/+0+0//g")
		# 将内容附加上去
		echo '<strong>'${pic/\.jpg/}' - '$imgsize':</strong><p><a href="data/attachment/portal/wallpaper/'$line'/'$pic'" target="_blank"><img src="/data/attachment/portal/wallpaper/'$line'/'$pic'"></a></p>' >> $CONTENT
	done < $TEMP
	
	# 去掉最后的 | 符号
	pic_list=${pic_list%%|}
	
	# 文件夹里jpg文件数量，用-l就避免了文件名空格问题
	pic_num=$( ls -l *.jpg | wc -l ) 
	
	# 将图片描述txt文件转换为UTF-8编码
	ls *.txt > $TEMP
	read textfile < $TEMP
	enca -L zh_CN -x UTF-8 < $textfile > $TEMP
	# 将纯文本用markdown转换为HTML格式
	text=`markdown $TEMP`
	# 将单引号转义
	esc_text=$( echo $text | sed "s/'/\\\\'/g" )
	
	# 写入内容尾部
	echo '<p>'$esc_text'</p></center></div>' >> $CONTENT
	
	content=$( cat $CONTENT )
	
	# 将拼凑好的内容写入SQL文件
	echo "CALL insert_wallpaper(26, 'admin', 98479, 1362640845, '"$line"', '"$thumb"', '"$pic_list"', "$pic_num", '"$content"');" >> $SQLFILE
	
done < $LIST

# rm $LIST

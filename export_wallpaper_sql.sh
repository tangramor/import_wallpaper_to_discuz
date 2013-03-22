#!/bin/bash

LIST=~/list.txt
TEMP=~/tmp.txt
TEMP2=/tmp/tmp2.txt
CONTENT=/tmp/content.txt
SQLFILE=~/wallpaper.sql

# ===============存储过程===============
#DROP PROCEDURE IF EXISTS insert_wallpaper;
#delimiter //
#CREATE PROCEDURE insert_wallpaper(
  #folder_name varchar(100) CHARACTER SET utf8, 
  #file1 varchar(100) CHARACTER SET utf8, 
  #file1size int(10) unsigned,
  #file2 varchar(100) CHARACTER SET utf8, 
  #file2size int(10) unsigned,
  #content text)
#BEGIN 
	#DECLARE aid BIGINT UNSIGNED;

	#INSERT INTO `alibbs_portal_article_title` (`catid`, `bid`, `uid`, `username`, `title`, `shorttitle`, `highlight`, `author`, `from`, `fromurl`, `url`, `summary`, `pic`, `thumb`, `remote`, `id`, `idtype`, `contents`, `allowcomment`, `owncomment`, `click1`, `click2`, `click3`, `click4`, `click5`, `click6`, `click7`, `click8`, `tag`, `dateline`, `status`, `showinnernav`) VALUES (26, 0, 1, 'admin', folder_name, '', '|||', '', '', '', '', '', CONCAT('portal/wallpaper/', folder_name, '/', file1), 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1362640845, 0, 0);
	
	#SET aid = last_insert_id();
	
	#INSERT INTO `alibbs_portal_attachment` (`uid`, `dateline`, `filename`, `filetype`, `filesize`, `attachment`, `isimage`, `thumb`, `remote`, `aid`) VALUES (98479, 1362640845, file1, 'jpg', file1size, CONCAT('wallpaper/', folder_name, '/', file1), 1, 1, 0, aid);
	
	#INSERT INTO `alibbs_portal_attachment` (`uid`, `dateline`, `filename`, `filetype`, `filesize`, `attachment`, `isimage`, `thumb`, `remote`, `aid`) VALUES (98479, 1362640845, file2, 'jpg', file2size, CONCAT('wallpaper/', folder_name, '/', file2), 1, 1, 0, aid);
 
	#INSERT INTO `alibbs_portal_article_content` (`aid`, `id`, `idtype`, `title`, `content`, `pageorder`, `dateline`) VALUES (aid, 0, '', '', content, 1, 1362640845);
#END;
# ===============存储过程===============

WORKDIR=`pwd`
cd $WORKDIR
rm -rf thumbs
rm -f $SQLFILE

ls > $LIST

mkdir thumbs

while read -r line
do
	cd "$WORKDIR/$line"
	
	rm -f thumb.*
	
	echo '<div><center>' > $CONTENT
	
	# 将图片文件名导入临时文件
	ls *.jpg > $TEMP
	
	# 用第一个图片生成缩略图
	read file1 < $TEMP
	thumb="thumb.$file1"
	if [ ! -f "$WORKDIR/thumbs/$thumb" ]; then
		convert -thumbnail 300x225 "$file1" "$WORKDIR/thumbs/$thumb"
	fi
		
	# 将换行符替换成|，最后会多一个|
	#temp=$( cat $TEMP | tr '\n' '|' )
	#pic_list=${temp%%|}
	
	pic_list=""
	while read pic; do
		pic_list="${pic}:"$( stat -c %s "${pic}" )"|"$pic_list
		imgsize=$( identify "$pic" > $TEMP2 && gawk '{print $4}' $TEMP2 | sed "s/+0+0//g")
		echo '<strong>'${pic/\.jpg/}' - '$imgsize':</strong><p><a href="data/attachment/portal/wallpaper/'$line'/'$pic'" target="_blank"><img src="/data/attachment/portal/wallpaper/'$line'/'$pic'"></a></p>' >> $CONTENT
	done < $TEMP
	
	pic_list=${pic_list%%|}
	
	pic_num=$( ls -l *.jpg | wc -l ) # 文件夹里jpg文件数量
	
	# 将图片描述txt文件转换为UTF-8编码
	ls *.txt > $TEMP
	read textfile < $TEMP
	enca -L zh_CN -x UTF-8 < $textfile > $TEMP
	# 将纯文本用markdown转换为HTML格式
	text=`markdown $TEMP`
	# 将单引号转义
	esc_text=$( echo $text | sed "s/'/\\\\'/g" )
	
	echo '<p>'$esc_text'</p></center></div>' >> $CONTENT
	
	content=$( cat $CONTENT )
	
	# 将拼凑好的内容写入SQL文件
	echo "CALL insert_wallpaper(26, 'admin', 98479, 1362640845, '"$line"', '"$thumb"', '"$pic_list"', "$pic_num", '"$content"');" >> $SQLFILE
	
done < $LIST

# rm $LIST

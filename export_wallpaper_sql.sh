#!/bin/bash

LIST=~/list.txt
TEMP=~/tmp.txt
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
ls > $LIST

while read -r line
do
	cd "$WORKDIR/${line// /\\ }"
	
	# 将图片文件名导入临时文件
	ls *.jpg > $TEMP
	# 第一个文件名
	read file1 < $TEMP
	# 第二个文件名
	file2=`sed -n 2p < $TEMP`
	
	# 文件大小
	size1=$( stat -c %s "$file1" )
	size2=$( stat -c %s "$file2" )
	
	# 图片长宽，本来字段3就是，但是有的文件名带空格……多于1个空格就不管了
	imgsize1=$( identify "$file1" > $TEMP && gawk '{print $4}' $TEMP | sed "s/+0+0//g")
	imgsize2=$( identify "$file2" > $TEMP && gawk '{print $4}' $TEMP | sed "s/+0+0//g" )
	
	# 将图片描述txt文件转换为UTF-8编码
	ls *.txt > $TEMP
	read textfile < $TEMP
	enca -L zh_CN -x UTF-8 < $textfile > $TEMP
	# 将纯文本用markdown转换为HTML格式
	text=`markdown $TEMP`
	# 将单引号转义
	esc_text=$( echo $text | sed "s/'/\\\\'/g" )
	
	content='<div><center><strong>'$imgsize1':</strong><p><a href="data/attachment/portal/wallpaper/'$line'/'$file1'" target="_blank"><img src="/data/attachment/portal/wallpaper/'$line'/'$file1'"></a></p><strong>'$imgsize2':</strong><p><a href="data/attachment/portal/wallpaper/'$line'/'$file2'" target="_blank"><img src="/data/attachment/portal/wallpaper/'$line'/'$file2'"></a></p><p>'$esc_text'</p></center></div>'
	
	# 将拼凑好的内容写入SQL文件
	echo "CALL insert_wallpaper('"$line"', '"$file1"', "$size1", '"$file2"', "$size2", '"$content"');" >> $SQLFILE
	
done < $LIST

# rm $LIST

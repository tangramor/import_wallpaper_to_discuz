DROP PROCEDURE IF EXISTS insert_wallpaper;
delimiter //
CREATE PROCEDURE insert_wallpaper(
  folder_name varchar(100) CHARACTER SET utf8, 
  file1 varchar(100) CHARACTER SET utf8, 
  file1size int(10) unsigned,
  file2 varchar(100) CHARACTER SET utf8, 
  file2size int(10) unsigned,
  content text)
BEGIN 
	DECLARE aid BIGINT UNSIGNED;

	INSERT INTO `alibbs_portal_article_title` (`catid`, `bid`, `uid`, `username`, `title`, `shorttitle`, `highlight`, `author`, `from`, `fromurl`, `url`, `summary`, `pic`, `thumb`, `remote`, `id`, `idtype`, `contents`, `allowcomment`, `owncomment`, `click1`, `click2`, `click3`, `click4`, `click5`, `click6`, `click7`, `click8`, `tag`, `dateline`, `status`, `showinnernav`) VALUES (26, 0, 1, 'admin', folder_name, '', '|||', '', '', '', '', '', CONCAT('portal/wallpaper/', folder_name, '/', file1), 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1362640845, 0, 0);
	
	SET aid = last_insert_id();
	
	INSERT INTO `alibbs_portal_attachment` (`uid`, `dateline`, `filename`, `filetype`, `filesize`, `attachment`, `isimage`, `thumb`, `remote`, `aid`) VALUES (98479, 1362640845, file1, 'jpg', file1size, CONCAT('wallpaper/', folder_name, '/', file1), 1, 1, 0, aid);
	
	INSERT INTO `alibbs_portal_attachment` (`uid`, `dateline`, `filename`, `filetype`, `filesize`, `attachment`, `isimage`, `thumb`, `remote`, `aid`) VALUES (98479, 1362640845, file2, 'jpg', file2size, CONCAT('wallpaper/', folder_name, '/', file2), 1, 1, 0, aid);
 
	INSERT INTO `alibbs_portal_article_content` (`aid`, `id`, `idtype`, `title`, `content`, `pageorder`, `dateline`) VALUES (aid, 0, '', '', content, 1, 1362640845);
END;

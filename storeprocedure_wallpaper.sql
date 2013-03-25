DELIMITER $$

DROP PROCEDURE IF EXISTS insert_wallpaper$$

CREATE PROCEDURE insert_wallpaper(
	catid int(10),
	uname varchar(100) CHARACTER SET utf8, 
	uid int(10),
	dateline int(10),
	folder_name varchar(100) CHARACTER SET utf8, 
	thumb varchar(100) CHARACTER SET utf8, 
	file_list varchar(1000) CHARACTER SET utf8,
	list_size int,
	content text)
BEGIN 
	DECLARE aid BIGINT UNSIGNED;
	DECLARE counter INT DEFAULT 0;
	DECLARE pic VARCHAR(255) CHARACTER SET utf8;
	DECLARE pic_name VARCHAR(100) CHARACTER SET utf8;
	DECLARE pic_size VARCHAR(20);

	INSERT INTO `ali_portal_article_title` (`catid`, `bid`, `uid`, `username`, `title`, `highlight`, `author`, `from`, `fromurl`, `url`, `summary`, `pic`, `thumb`, `remote`, `id`, `idtype`, `contents`, `allowcomment`, `owncomment`, `click1`, `click2`, `click3`, `click4`, `click5`, `click6`, `click7`, `click8`, `tag`, `dateline`, `status`, `showinnernav`) VALUES (catid, 0, 1, uname, folder_name, '|||', '', '', '', '', '', CONCAT('portal/wallpaper/thumbs/', thumb), 0, 0, 0, '', 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, dateline, 0, 0);
	
	SET aid = last_insert_id();
	
	
	simple_loop: LOOP
		SET counter = counter + 1;
		
		SELECT strSplit(file_list, '|', counter) INTO pic;
		SELECT strSplit(pic, ':', 1) INTO pic_name;
		SELECT strSplit(pic, ':', 2) INTO pic_size;
		INSERT INTO `ali_portal_attachment` (`uid`, `dateline`, `filename`, `filetype`, `filesize`, `attachment`, `isimage`, `thumb`, `remote`, `aid`) VALUES (uid, dateline, pic_name, 'jpg', CAST(pic_size AS UNSIGNED), CONCAT('wallpaper/', folder_name, '/', pic_name), 1, 1, 0, aid);
		
		IF counter = list_size THEN
			-- break out since we have done parsing
			LEAVE simple_loop;
		END IF;
	END LOOP simple_loop;
	
	INSERT INTO `ali_portal_article_content` (`aid`, `id`, `idtype`, `title`, `content`, `pageorder`, `dateline`) VALUES (aid, 0, '', '', content, 1, dateline);
END$$

DELIMITER;

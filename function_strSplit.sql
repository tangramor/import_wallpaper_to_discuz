DELIMITER $$

DROP FUNCTION IF EXISTS `strSplit`$$

CREATE 

FUNCTION `strSplit`(
	x varchar(255) CHARACTER SET utf8, 
	delim varchar(12) CHARACTER SET utf8, 
	pos int) 
	
	RETURNS varchar(255) CHARSET utf8
	
DETERMINISTIC

BEGIN
   RETURN replace(substring(substring_index(x, delim, pos), 
      char_length(substring_index(x, delim, pos - 1)) + 1), delim, '');
	
-- end the stored function code block
END$$

DELIMITER;

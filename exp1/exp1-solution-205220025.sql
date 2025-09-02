-- 姓名：郑凯琳
-- 学号：205220025
-- 提交前请确保本次实验独立完成，若有参考请注明并致谢。

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1

SELECT COUNT(*) AS 'speciesCount'
FROM species
WHERE description LIKE '%this%';

-- END Q1

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2

SELECT username, SUM(PH.power)AS totalPhonemonPower
FROM player P
JOIN phonemon PH ON P.id = PH.player
WHERE P.username IN ('Cook', 'Hughes')
GROUP BY P.username;

-- END Q2

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3

SELECT T.title, COUNT(P.id) AS numberOfPlayers
FROM team T
JOIN player P ON T.id = P.team
GROUP BY T.title
ORDER BY numberOfPlayers DESC;

-- END Q3

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4

SELECT S.id AS idSpecies, S.title
FROM species S
JOIN type T ON S.type1 = T.id OR S.type2 = T.id
WHERE T.title = 'grass';

-- END Q4

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5

SELECT P.id AS idPlayer, P.username
FROM player P
WHERE P.id NOT IN(
	SELECT PU.player
    FROM purchase PU
    JOIN item I ON PU.item = I.id
    WHERE I.type = 'F'
);

-- END Q5

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6

SELECT P.level, SUM(PU.quantity * I.price) AS totalAmountSpentByAllPlayersAtLevel
FROM player P
JOIN purchase PU ON P.id = PU.player
JOIN item I ON PU.item = I.id
GROUP BY P.level
ORDER BY totalAmountSpentByAllPlayersAtLevel DESC;

-- END Q6

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7

SELECT I.id AS item, i.title, COUNT(PU.id) AS numTimesPurchased
FROM purchase PU
JOIN item I ON PU.item = I.id
GROUP BY I.id 
HAVING COUNT(PU.id) = (
	SELECT MAX(counts.num)
    FROM (SELECT COUNT(*) AS num FROM purchase GROUP BY item) counts
);

-- END Q7

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8

SELECT P.id AS playerID, P.username, COUNT(DISTINCT I.id) AS numberDistinctFoodItemsPurchased
FROM player P
JOIN purchase PU ON P.id = PU.player
JOIN item I ON PU.item = I.id
WHERE I.type = 'F'
GROUP BY P.id, P.username
HAVING COUNT(DISTINCT I.id) = (
	SELECT COUNT(DISTINCT id) FROM item WHERE type = 'F'
);

-- END Q8

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9

SELECT
	COUNT(*) AS numberOfPhonemonPairs,
    ROUND(SQRT(POWER((P1.latitude - P2.latitude), 2) + POWER((P1.longitude - P2.longitude), 2)) * 100, 2) AS distanceX
FROM phonemon P1, phonemon P2
WHERE P1.id < P2.id
GROUP BY distanceX
HAVING distanceX <= ALL(
	SELECT
		ROUND(SQRT(POWER((P1.latitude - P2.latitude), 2) + POWER((P1.longitude - P2.longitude), 2)) * 100, 2) AS distanceX
	FROM phonemon P1, phonemon P2
	WHERE P1.id < P2.id
);

-- END Q9

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10

SELECT T.username, T.typeTitle
FROM
(
	SELECT player.username AS username, type.title AS typeTitle, type.id
	FROM player, phonemon, species, type
	WHERE player.id = phonemon.player 
		AND phonemon.species = species.id 
        AND (species.type1 = type.id OR species.type2 = type.id)
	GROUP BY player.id, type.id
	HAVING COUNT(DISTINCT species.id) = (
		SELECT COUNT(*) FROM species WHERE species.type1 = type.id or species.type2 = type.id
	)
)AS T

-- END Q10
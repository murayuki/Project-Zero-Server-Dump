USE `es_extended`;

INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_police', 'Police', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('police', 'LSPD')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recruit','Recrue',20,'{}','{}'),
	('police',1,'officer','Officier',40,'{}','{}'),
	('police',2,'sergeant','Sergent',60,'{}','{}'),
	('police',3,'lieutenant','Lieutenant',85,'{}','{}'),
	('police',4,'boss','Commandant',100,'{}','{}')
;

CREATE TABLE `fine_types` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`label` varchar(255) DEFAULT NULL,
	`amount` int(11) DEFAULT NULL,
	`category` int(11) DEFAULT NULL,

	PRIMARY KEY (`id`)
);

INSERT INTO `fine_types` (label, amount, category) VALUES
	('Usage abusif du klaxon',30,0),
	('Franchir une ligne continue',40,0),
	('Circulation à contresens',250,0),
	('Demi-tour non autorisé',250,0),
	('Circulation hors-route',170,0),
	('Non-respect des distances de sécurité',30,0),
	('Arrêt dangereux / interdit',150,0),
	('Stationnement gênant / interdit',70,0),
	('Non respect  de la priorité à droite',70,0),
	('Non-respect à un véhicule prioritaire',90,0),
	('Non-respect d\'un stop',105,0),
	('Non-respect d\'un feu rouge',130,0),
	('Dépassement dangereux',100,0),
	('Véhicule non en état',100,0),
	('Conduite sans permis',1500,0),
	('Délit de fuite',800,0),
	('Excès de vitesse < 5 kmh',90,0),
	('Excès de vitesse 5-15 kmh',120,0),
	('Excès de vitesse 15-30 kmh',180,0),
	('Excès de vitesse > 30 kmh',300,0),
	('Entrave de la circulation',110,1),
	('Dégradation de la voie publique',90,1),
	('Trouble à l\'ordre publique',90,1),
	('Entrave opération de police',130,1),
	('Insulte envers / entre civils',75,1),
	('Outrage à agent de police',110,1),
	('Menace verbale ou intimidation envers civil',90,1),
	('Menace verbale ou intimidation envers policier',150,1),
	('Manifestation illégale',250,1),
	('Tentative de corruption',1500,1),
	('Arme blanche sortie en ville',120,2),
	('Arme léthale sortie en ville',300,2),
	('Port d\'arme non autorisé (défaut de license)',600,2),
	('Port d\'arme illégal',700,2),
	('Pris en flag lockpick',300,2),
	('Vol de voiture',1800,2),
	('Vente de drogue',1500,2),
	('Fabriquation de drogue',1500,2),
	('Possession de drogue',650,2),
	('Prise d\'ôtage civil',1500,2),
	('Prise d\'ôtage agent de l\'état',2000,2),
	('Braquage particulier',650,2),
	('Braquage magasin',650,2),
	('Braquage de banque',1500,2),
	('Tir sur civil',2000,3),
	('Tir sur agent de l\'état',2500,3),
	('Tentative de meurtre sur civil',3000,3),
	('Tentative de meurtre sur agent de l\'état',5000,3),
	('Meurtre sur civil',10000,3),
	('Meurte sur agent de l\'état',30000,3),
	('Meurtre involontaire',1800,3),
	('Escroquerie à l\'entreprise',2000,2)
;



INSERT INTO `jobs` (name, label) VALUES
	('offpolice', 'LSPD')
;


INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('police',0,'recluta','Agente en prácticas',100,'{}','{}'),
	('police',1,'cadete','Cadete',100,'{}','{}'),
	('police',2,'oficialuno','Oficial I',100,'{}','{}'),
	('police',3,'oficialdos','Oficial II',100,'{}','{}'),
	('police',4,'oficialtres','Oficial III',100,'{}','{}'),
	('police',5,'sargento','Sargento',100,'{}','{}'),
	('police',6,'teniente','Teniente',100,'{}','{}'),
	('police',7,'capitan','Capitán',100,'{}','{}'),
	('police',8,'comandante','Comandante',100,'{}','{}'),
	('police',9,'jefesuper','Jefe supervisor',100,'{}','{}'),
	('police',10,'jefeadjun','Jefe adjunto',100,'{}','{}'),
	('police',11,'boss','Jefe',100,'{}','{}'),
	('offpolice',0,'recluta','Fuera de servicio',100,'{}','{}'),
	('offpolice',1,'cadete','Fuera de servicio',100,'{}','{}'),
	('offpolice',2,'oficialuno','Fuera de servicio',100,'{}','{}'),
	('offpolice',3,'oficialdos','Fuera de servicio',100,'{}','{}'),
	('offpolice',4,'oficialtres','Fuera de servicio',100,'{}','{}'),
	('offpolice',5,'sargento','Fuera de servicio',100,'{}','{}'),
	('offpolice',6,'teniente','Fuera de servicio',100,'{}','{}'),
	('offpolice',7,'capitan','Fuera de servicio',100,'{}','{}'),
	('offpolice',8,'comandante','Fuera de servicio',100,'{}','{}'),
	('offpolice',9,'jefesuper','Fuera de servicio',100,'{}','{}'),
	('offpolice',10,'jefeadjun','Fuera de servicio',100,'{}','{}'),
	('offpolice',11,'boss','Fuera de servicio',100,'{}','{}'),
;


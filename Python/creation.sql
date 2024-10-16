DROP SCHEMA IF EXISTS projet CASCADE;

CREATE SCHEMA projet;

CREATE SEQUENCE seq_idClientParticulier increment BY 2 START 1;
CREATE SEQUENCE seq_idClientProfessionnel increment BY 2 START 2;
/* id clients particuliers : nombres impairs
id clients pro : nombres pairs */


CREATE TABLE projet.Options (
	nom VARCHAR PRIMARY KEY
);

CREATE TABLE projet.CategorieVehicule (
  nom VARCHAR PRIMARY KEY
);

CREATE TABLE projet.TypeCarburant (
  nom VARCHAR PRIMARY KEY
);

CREATE TABLE projet.Agence (
  nom VARCHAR PRIMARY KEY
);

CREATE TABLE projet.AgentCommercial (
  numSecuSociale INTEGER PRIMARY KEY,
  nom VARCHAR NOT NULL,
  prenom VARCHAR NOT NULL,
  dateNaissance DATE NOT NULL,
  agence VARCHAR NOT NULL,
  FOREIGN KEY(agence) REFERENCES projet.Agence(nom)
);

CREATE TABLE projet.Modele (
  nomModele VARCHAR PRIMARY KEY,
  nbPortes INTEGER NOT NULL CHECK (nbPortes>= 3 AND nbPortes <=5),
  categorie VARCHAR NOT NULL,
  FOREIGN KEY(categorie) REFERENCES projet.CategorieVehicule(nom)
);

CREATE TABLE projet.Vehicule (
  immat VARCHAR PRIMARY KEY,
  marque VARCHAR NOT NULL,
  couleur VARCHAR NOT NULL,
  tarif FLOAT(8) NOT NULL,
  km INTEGER NOT NULL,
  nomModele VARCHAR NOT NULL,
  typeCarburant VARCHAR NOT NULL,
  agence VARCHAR NOT NULL,
  FOREIGN KEY(nomModele) REFERENCES projet.Modele(nomModele),
  FOREIGN KEY(typeCarburant) REFERENCES projet.TypeCarburant(nom),
  FOREIGN KEY(agence) REFERENCES projet.Agence(nom)
);

CREATE TABLE projet.AssocOptions (
	vehicule VARCHAR NOT NULL,
	option VARCHAR NOT NULL,
	PRIMARY KEY (vehicule, option),
	FOREIGN KEY(vehicule) REFERENCES projet.Vehicule(immat),
	FOREIGN KEY(option) REFERENCES projet.Options(nom)
);

CREATE TABLE projet.Facturation (
	idFact SERIAL PRIMARY KEY,
	dateFacturation DATE,
	moyenReglement VARCHAR CHECK (moyenReglement='CB' OR moyenReglement='cheque' 
		OR moyenReglement='especes' OR moyenReglement='virement'),
	montant FLOAT(8),
	agentCommercial INTEGER NOT NULL,
	FOREIGN KEY(agentCommercial) REFERENCES projet.AgentCommercial(numSecuSociale)
);

CREATE TABLE projet.ClientProfessionnel (
  idCLient INTEGER PRIMARY KEY,
  idEntreprise SERIAL,
  nom VARCHAR NOT NULL,
  infosEntreprise VARCHAR
);

CREATE TABLE projet.ClientParticulier (
  idClient INTEGER PRIMARY KEY,
  numeroPermis VARCHAR UNIQUE NOT NULL,
  nom VARCHAR NOT NULL,
  prenom VARCHAR NOT NULL,
  adresse VARCHAR,
  numeroTel VARCHAR NOT NULL,
  dateNaissance DATE NOT NULL CHECK (age(dateNaissance) > interval '20 years')
  /* ClientParticulier.idClient XOR ClientProfessionel.idClient 
    # contrainte réalisée dans la couche applicative
    # sinon utilisation de "trigger" : pas au programme
  */
);

CREATE TABLE projet.Conducteur (
  numeroPermis VARCHAR PRIMARY KEY,
  nom VARCHAR NOT NULL,
  prenom VARCHAR NOT NULL,
  adresse VARCHAR,
  numeroTel VARCHAR NOT NULL,
  dateNaissance DATE NOT NULL CHECK (age(dateNaissance) > interval '20 years'),
  clientProfessionnel INTEGER NOT NULL,
  FOREIGN KEY (clientProfessionnel) REFERENCES projet.ClientProfessionnel(idClient)
);

CREATE TABLE projet.SocieteEntretien (
    idSociete SERIAL PRIMARY KEY,
    nom VARCHAR NOT NULL,
    agence VARCHAR NOT NULL,
    FOREIGN KEY(agence) REFERENCES projet.Agence(nom)
);

CREATE TABLE projet.AgentTechnique (
    numSecuSociale INTEGER PRIMARY KEY,
    nom VARCHAR NOT NULL,
    prenom VARCHAR NOT NULL,
    dateNaissance DATE NOT NULL,
    agence VARCHAR NOT NULL,
    FOREIGN KEY(agence) REFERENCES projet.Agence(nom)
);

CREATE TABLE projet.Entretien (
  numeroEntretien SERIAL PRIMARY KEY,
  dateEntretien DATE NOT NULL,
  societeEntretien INTEGER,
  agentTechnique INTEGER,
  FOREIGN KEY (societeEntretien) REFERENCES projet.SocieteEntretien(idSociete),
  FOREIGN KEY (agentTechnique) REFERENCES projet.AgentTechnique(numSecuSociale),
  CONSTRAINT xor CHECK ((agentTechnique IS NULL OR societeEntretien IS NULL) 
    AND (agentTechnique IS NOT NULL OR societeEntretien IS NOT NULL))
);

CREATE TABLE projet.ContratLocation (
    idContrat SERIAL PRIMARY KEY,
    dateReservation DATE  NOT NULL,
    heureDebut TIME  NOT NULL,
    heureFin TIME NOT NULL,
    dateDebutLocation DATE  NOT NULL,
    dateFinLocation DATE  NOT NULL,
    kilometrage INTEGER,
    vehicule VARCHAR NOT NULL,
    agent INTEGER,
    facturation INTEGER NOT NULL,
    entretien INTEGER UNIQUE,
    FOREIGN KEY(vehicule) REFERENCES projet.Vehicule(immat),
    FOREIGN KEY(agent) REFERENCES projet.AgentCommercial(numSecuSociale),
    FOREIGN KEY(facturation) REFERENCES projet.Facturation(idFact),
    FOREIGN KEY(entretien) REFERENCES projet.Entretien(numeroEntretien),
    CONSTRAINT check_date CHECK((DateDebutLocation < DateFinLocation)
      OR (DateDebutLocation = DateFinLocation AND heureDebut < heureFin))
    /* dateFinLocation < dateEntretien */
);

CREATE TABLE projet.ContratParticulier (
    idContrat INTEGER PRIMARY KEY,
    clientParticulier INTEGER NOT NULL,
    FOREIGN KEY (idContrat) REFERENCES projet.ContratLocation(idContrat),
    FOREIGN KEY(clientParticulier) REFERENCES projet.ClientParticulier(idClient)
);

CREATE TABLE projet.ContratProfessionnel (
    idContrat INTEGER PRIMARY KEY,
    conducteur VARCHAR NOT NULL,
    FOREIGN KEY (idContrat) REFERENCES projet.ContratLocation(idContrat),
    FOREIGN KEY(conducteur) REFERENCES projet.Conducteur(numeroPermis)   
); 


/* TABLE Options */
INSERT INTO projet.Options VALUES('toit panoramique');
INSERT INTO projet.Options VALUES('vitres teintees');
INSERT INTO projet.Options VALUES('camera de recul');
INSERT INTO projet.Options VALUES('GPS');
INSERT INTO projet.Options VALUES('aide au stationnement');
INSERT INTO projet.Options VALUES('radar de recul');
INSERT INTO projet.Options VALUES('autoradio tactile');
INSERT INTO projet.Options VALUES('climatisation');
INSERT INTO projet.Options VALUES('sieges chauffants');
INSERT INTO projet.Options VALUES('lecteurs DVD');

/* TABLE CategorieVehicule */
INSERT INTO projet.CategorieVehicule VALUES('citadine');
INSERT INTO projet.CategorieVehicule VALUES('berline petite');
INSERT INTO projet.CategorieVehicule VALUES('berline moyenne');
INSERT INTO projet.CategorieVehicule VALUES('berline grande');
INSERT INTO projet.CategorieVehicule VALUES('4X4');
INSERT INTO projet.CategorieVehicule VALUES('SUV' );
INSERT INTO projet.CategorieVehicule VALUES('break');
INSERT INTO projet.CategorieVehicule VALUES('pickup');
INSERT INTO projet.CategorieVehicule VALUES('utilitaire');

/* TABLE TypeCarburant */
INSERT INTO projet.TypeCarburant VALUES('E10');
INSERT INTO projet.TypeCarburant VALUES('E5');
INSERT INTO projet.TypeCarburant VALUES('E85');
INSERT INTO projet.TypeCarburant VALUES('B7');
INSERT INTO projet.TypeCarburant VALUES('B10');
INSERT INTO projet.TypeCarburant VALUES('XTL');
INSERT INTO projet.TypeCarburant VALUES('Electricite');

/* TABLE Agence */
INSERT INTO projet.Agence VALUES('Rent A Car Compiegne');
INSERT INTO projet.Agence VALUES('Kayak Compiegne');
INSERT INTO projet.Agence VALUES('ADA Venette');
INSERT INTO projet.Agence VALUES('France Cars Venette');
INSERT INTO projet.Agence VALUES('Super U Compiegne');
INSERT INTO projet.Agence VALUES('Carrefour Location Compiegne');
INSERT INTO projet.Agence VALUES('Europcar Compiegne');
INSERT INTO projet.Agence VALUES('Midas Venette');
INSERT INTO projet.Agence VALUES('Kayak Amiens');
INSERT INTO projet.Agence VALUES('ADA Amiens');

/* TABLE AgentCommercial */
INSERT INTO projet.AgentCommercial VALUES(11824521, 'Martin', 'Gabriel', '1986-09-20', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(16001022, 'Bernard', 'Leo', '1987-07-26', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(18525423, 'Thomas', 'Raphael', '1988-11-04', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(15065724, 'Petit', 'Arthur', '1989-01-25', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(13324025, 'Robert', 'Louis', '1989-02-18', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(26349226, 'Richard', 'Jade', '1989-05-28', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(29552327, 'Durand', 'Louise', '1989-12-24', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(29321328, 'Dubois', 'Alice', '1990-01-04', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(24242429, 'Moreau', 'Lina', '1992-04-09', 'Rent A Car Compiegne');
INSERT INTO projet.AgentCommercial VALUES(23249220, 'Laurent', 'Chloe', '1992-06-04', 'Rent A Car Compiegne');

/* TABLE AgentTechnique */
INSERT INTO projet.AgentTechnique VALUES(11073451, 'Simon', 'Lucas', '1992-10-13', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(18473452, 'Michel', 'Adam', '1992-12-29', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(10634353, 'Lefevre', 'Jules', '1993-02-12', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(18934154, 'Leroy', 'Hugo', '1993-10-14', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(19343545, 'Leroy', 'Mael', '1994-02-15', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(29243556, 'David', 'Emma', '1994-06-24', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(29424257, 'Bertrand', 'Mia', '1994-12-11', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(24344958, 'Morel', 'Ines', '1996-11-06', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(26348159, 'Fournier', 'Lea', '1996-11-28', 'Rent A Car Compiegne');
INSERT INTO projet.AgentTechnique VALUES(25623150, 'Girard', 'Rose', '1997-03-14', 'Rent A Car Compiegne');

/* TABLE Modele */
INSERT INTO projet.Modele VALUES('Clio', 5, 'citadine');
INSERT INTO projet.Modele VALUES('Captur', 5, 'SUV');
INSERT INTO projet.Modele VALUES('Ranger', 3, '4X4');
INSERT INTO projet.Modele VALUES('Transit', 5, 'utilitaire');
INSERT INTO projet.Modele VALUES('Transit 2T', 5, 'utilitaire');
INSERT INTO projet.Modele VALUES('508', 5, 'berline moyenne');
INSERT INTO projet.Modele VALUES('308', 5, 'citadine');
INSERT INTO projet.Modele VALUES('5008', 5, 'SUV');
INSERT INTO projet.Modele VALUES('Polo', 5, 'citadine');
INSERT INTO projet.Modele VALUES('Pasat', 5, 'berline grande');
INSERT INTO projet.Modele VALUES('Yaris', 5, 'citadine');
INSERT INTO projet.Modele VALUES('Corolla', 5, 'citadine');
INSERT INTO projet.Modele VALUES('Hylux', 3, '4X4');

/* TABLE Vehicule */
INSERT INTO projet.Vehicule VALUES('YP6IQD8', 'Renault', 'blanc', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('JQUL6IJ', 'Renault', 'blanc', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('SE2QLTO', 'Renault', 'noir', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('GDVH2T4', 'Renault', 'noir', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('MLF08ET', 'Renault', 'rouge', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('PPHS3OQ', 'Renault', 'rouge', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('BT4NJXD', 'Renault', 'blue', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('22VM6BN', 'Renault', 'blue', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('1SBIWCJ', 'Renault', 'gris', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('L1NP2LI', 'Renault', 'gris', 186, 0, 'Clio', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('9GT42QJ', 'Renault', 'blanc', 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('8253Y3Z', 'Renault', 'blanc', 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('SZKXIY9', 'Renault', 'noir' , 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('NJ9L6FP', 'Renault', 'noir' , 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('2B7EABE', 'Renault', 'rouge', 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('WKUU8CQ', 'Renault', 'rouge', 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('0CURA9S', 'Renault', 'blue' , 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('NNCLA0K', 'Renault', 'blue' , 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('MY6EVLB', 'Renault', 'gris' , 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('FDCTZX1', 'Renault', 'gris' , 192, 0, 'Captur', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('RRXWUIV', 'Ford', 'blanc', 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('DRBZ26L', 'Ford', 'blanc', 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('IBO3LA2', 'Ford', 'noir' , 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('2WIYOH5', 'Ford', 'noir' , 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('0JFLC1Y', 'Ford', 'rouge', 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('4FPK7VW', 'Ford', 'rouge', 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('3FS1I81', 'Ford', 'blue' , 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('LWJM412', 'Ford', 'blue' , 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('XUDQWPF', 'Ford', 'gris' , 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('BXAQQ5I', 'Ford', 'gris' , 192, 0, 'Ranger', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('LVH0Q7M', 'Ford', 'blanc', 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('V3E8WWW', 'Ford', 'blanc', 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('WFLVNG5', 'Ford', 'noir' , 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('I5OAZ78', 'Ford', 'noir' , 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('N0I8J2I', 'Ford', 'rouge', 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('RHUB7FW', 'Ford', 'rouge', 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('KCDJUHU', 'Ford', 'blue' , 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('2LLCLWU', 'Ford', 'blue' , 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('55HMZCX', 'Ford', 'gris' , 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('SM2SXQZ', 'Ford', 'gris' , 250, 0, 'Transit', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('ME45Q7Q', 'Ford', 'blanc', 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('DYAI4EJ', 'Ford', 'blanc', 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('5NJRHF6', 'Ford', 'noir' , 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('22MQGQ0', 'Ford', 'noir' , 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('8OBST8R', 'Ford', 'rouge', 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('2HAYQGU', 'Ford', 'rouge', 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('NKP0CGQ', 'Ford', 'blue' , 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('QGXF6JH', 'Ford', 'blue' , 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('MWKAVL7', 'Ford', 'gris' , 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('4SZZSKP', 'Ford', 'gris' , 200, 0, 'Transit 2T', 'XTL', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('V62MHCL', 'Peugeot', 'blanc', 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('YDCKJIU', 'Peugeot', 'blanc', 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('9NBKIFC', 'Peugeot', 'noir' , 201, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('6M89JH4', 'Peugeot', 'noir' , 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('SS4GH0X', 'Peugeot', 'rouge', 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('VE65M59', 'Peugeot', 'rouge', 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('YQSV1KD', 'Peugeot', 'blue' , 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('XACZKOB', 'Peugeot', 'blue' , 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('IZMU4DI', 'Peugeot', 'gris' , 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('RTPX4KO', 'Peugeot', 'gris' , 225, 0, '508', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('V7ZBV5W', 'Peugeot', 'blanc', 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('FRIW5RF', 'Peugeot', 'blanc', 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('YUR9GNB', 'Peugeot', 'noir' , 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('ZBKTSXH', 'Peugeot', 'noir' , 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('4C7PSPI', 'Peugeot', 'rouge', 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('RBQSPVS', 'Peugeot', 'rouge', 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('N44ZDR7', 'Peugeot', 'blue' , 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('BUPKDTG', 'Peugeot', 'blue' , 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('1P2728G', 'Peugeot', 'gris' , 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('ZRIE4GS', 'Peugeot', 'gris' , 250, 0, '5008', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('D6RWH3W', 'Peugeot', 'blanc', 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('L0ISBTF', 'Peugeot', 'blanc', 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('Y4RCQ7K', 'Peugeot', 'noir' , 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('Y2SJQDL', 'Peugeot', 'noir' , 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('GL19SG0', 'Peugeot', 'rouge', 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('K2ZRMT9', 'Peugeot', 'rouge', 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('2DNCD8R', 'Peugeot', 'blue' , 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('6L7INEF', 'Peugeot', 'blue' , 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('ZOLUMHX', 'Peugeot', 'gris' , 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('VO4MLK2', 'Peugeot', 'gris' , 201, 0, '308', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('2XTXUDI', 'Volskwagen', 'blanc', 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('GVLVNBD', 'Volskwagen', 'blanc', 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('U8UT6U7', 'Volskwagen', 'noir' , 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('K0X57PW', 'Volskwagen', 'noir' , 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('TT3TZQC', 'Volskwagen', 'rouge', 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('T8W4EBU', 'Volskwagen', 'rouge', 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('X0O59XN', 'Volskwagen', 'blue' , 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('89TFFMZ', 'Volskwagen', 'blue' , 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('77BP57L', 'Volskwagen', 'gris' , 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('NL2BOX4', 'Volskwagen', 'gris' , 185, 0, 'Polo', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('4FK0HHH', 'Volskwagen', 'blanc', 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('NCWGVYS', 'Volskwagen', 'blanc', 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('YLDHKTX', 'Volskwagen', 'noir' , 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('UVDLYL0', 'Volskwagen', 'noir' , 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('9SESKEL', 'Volskwagen', 'rouge', 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('5JWWRUH', 'Volskwagen', 'rouge', 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('PZG0LB0', 'Volskwagen', 'blue' , 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('9VT8Q3L', 'Volskwagen', 'blue' , 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('YAM21OQ', 'Volskwagen', 'gris' , 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('VMJP8LV', 'Volskwagen', 'gris' , 294, 0, 'Pasat', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('K1R1WS8', 'Toyota', 'blanc', 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('PAZVT5Y', 'Toyota', 'blanc', 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('EPH4C9I', 'Toyota', 'noir' , 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('JGJKGAT', 'Toyota', 'noir' , 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('VF2XZDX', 'Toyota', 'rouge', 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('37U74RT', 'Toyota', 'rouge', 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('XJQLHBU', 'Toyota', 'blue' , 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('X581DWS', 'Toyota', 'blue' , 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('FXBHFC6', 'Toyota', 'gris' , 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('PX58AP2', 'Toyota', 'gris' , 180, 0, 'Yaris', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('T3P0ZEA', 'Toyota', 'blanc', 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('O2N7BKR', 'Toyota', 'blanc', 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('BL7IMIN', 'Toyota', 'noir' , 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('6ZV8W97', 'Toyota', 'noir' , 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('GB579LW', 'Toyota', 'rouge', 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('K87DITE', 'Toyota', 'rouge', 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('7ZXD5HK', 'Toyota', 'blue' , 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('UXPE8MN', 'Toyota', 'blue' , 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('SD2EUNC', 'Toyota', 'gris' , 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('6V58398', 'Toyota', 'gris' , 200, 0, 'Corolla', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('1YI2044', 'Toyota', 'blanc', 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('YFD7F4S', 'Toyota', 'blanc', 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('SC8OA7C', 'Toyota', 'noir' , 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('FJVSH58', 'Toyota', 'noir' , 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('GYTAMTM', 'Toyota', 'rouge', 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('T8EBFJ8', 'Toyota', 'rouge', 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('VU3NB9R', 'Toyota', 'blue' , 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('PS77YHM', 'Toyota', 'blue' , 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('VIN6TOC', 'Toyota', 'gris' , 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');
INSERT INTO projet.Vehicule VALUES('JX9SPE8', 'Toyota', 'gris' , 250, 0, 'Hylux', 'E5', 'Rent A Car Compiegne');

/* TABLE AssocOptions */
INSERT INTO projet.AssocOptions VALUES('YP6IQD8', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('JQUL6IJ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('SE2QLTO', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('GDVH2T4', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('MLF08ET', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('PPHS3OQ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('BT4NJXD', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('22VM6BN', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('1SBIWCJ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('L1NP2LI', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('RRXWUIV', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('DRBZ26L', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('IBO3LA2', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('2WIYOH5', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('0JFLC1Y', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('4FPK7VW', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('3FS1I81', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('LWJM412', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('XUDQWPF', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('BXAQQ5I', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('LVH0Q7M', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('V3E8WWW', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('WFLVNG5', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('I5OAZ78', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('N0I8J2I', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('RHUB7FW', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('KCDJUHU', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('2LLCLWU', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('55HMZCX', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('SM2SXQZ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('ME45Q7Q', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('DYAI4EJ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('5NJRHF6', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('22MQGQ0', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('8OBST8R', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('2HAYQGU', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('NKP0CGQ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('QGXF6JH', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('MWKAVL7', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('4SZZSKP', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('D6RWH3W', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('L0ISBTF', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('Y4RCQ7K', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('Y2SJQDL', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('GL19SG0', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('K2ZRMT9', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('2DNCD8R', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('6L7INEF', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('ZOLUMHX', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('VO4MLK2', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('2XTXUDI', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('GVLVNBD', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('U8UT6U7', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('K0X57PW', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('TT3TZQC', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('T8W4EBU', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('X0O59XN', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('89TFFMZ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('77BP57L', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('NL2BOX4', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('K1R1WS8', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('PAZVT5Y', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('EPH4C9I', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('JGJKGAT', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('VF2XZDX', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('37U74RT', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('XJQLHBU', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('X581DWS', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('FXBHFC6', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('PX58AP2', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('YFD7F4S', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('SC8OA7C', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('FJVSH58', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('GYTAMTM', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('T8EBFJ8', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('VU3NB9R', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('PS77YHM', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('VIN6TOC', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('JX9SPE8', 'camera de recul');
INSERT INTO projet.AssocOptions VALUES('1YI2044', 'camera de recul');

INSERT INTO projet.AssocOptions VALUES('YP6IQD8', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('JQUL6IJ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('SE2QLTO', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('GDVH2T4', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('MLF08ET', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('PPHS3OQ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('BT4NJXD', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('22VM6BN', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('1SBIWCJ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('L1NP2LI', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('RRXWUIV', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('DRBZ26L', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('IBO3LA2', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('2WIYOH5', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('0JFLC1Y', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('4FPK7VW', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('3FS1I81', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('LWJM412', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('XUDQWPF', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('BXAQQ5I', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('LVH0Q7M', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('V3E8WWW', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('WFLVNG5', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('I5OAZ78', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('N0I8J2I', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('RHUB7FW', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('KCDJUHU', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('2LLCLWU', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('55HMZCX', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('SM2SXQZ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('ME45Q7Q', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('DYAI4EJ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('5NJRHF6', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('22MQGQ0', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('8OBST8R', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('2HAYQGU', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('NKP0CGQ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('QGXF6JH', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('MWKAVL7', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('4SZZSKP', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('D6RWH3W', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('L0ISBTF', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('Y4RCQ7K', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('Y2SJQDL', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('GL19SG0', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('K2ZRMT9', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('2DNCD8R', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('6L7INEF', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('ZOLUMHX', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('VO4MLK2', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('2XTXUDI', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('GVLVNBD', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('U8UT6U7', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('K0X57PW', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('TT3TZQC', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('T8W4EBU', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('X0O59XN', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('89TFFMZ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('77BP57L', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('NL2BOX4', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('K1R1WS8', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('PAZVT5Y', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('EPH4C9I', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('JGJKGAT', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('VF2XZDX', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('37U74RT', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('XJQLHBU', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('X581DWS', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('FXBHFC6', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('PX58AP2', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('YFD7F4S', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('SC8OA7C', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('FJVSH58', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('GYTAMTM', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('T8EBFJ8', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('VU3NB9R', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('PS77YHM', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('VIN6TOC', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('JX9SPE8', 'aide au stationnement');
INSERT INTO projet.AssocOptions VALUES('1YI2044', 'aide au stationnement');

INSERT INTO projet.AssocOptions VALUES('YP6IQD8', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('JQUL6IJ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('SE2QLTO', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('GDVH2T4', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('MLF08ET', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('PPHS3OQ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('BT4NJXD', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('22VM6BN', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('1SBIWCJ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('L1NP2LI', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('RRXWUIV', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('DRBZ26L', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('IBO3LA2', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('2WIYOH5', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('0JFLC1Y', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('4FPK7VW', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('3FS1I81', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('LWJM412', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('XUDQWPF', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('BXAQQ5I', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('LVH0Q7M', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('V3E8WWW', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('WFLVNG5', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('I5OAZ78', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('N0I8J2I', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('RHUB7FW', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('KCDJUHU', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('2LLCLWU', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('55HMZCX', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('SM2SXQZ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('ME45Q7Q', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('DYAI4EJ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('5NJRHF6', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('22MQGQ0', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('8OBST8R', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('2HAYQGU', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('NKP0CGQ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('QGXF6JH', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('MWKAVL7', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('4SZZSKP', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('D6RWH3W', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('L0ISBTF', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('Y4RCQ7K', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('Y2SJQDL', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('GL19SG0', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('K2ZRMT9', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('2DNCD8R', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('6L7INEF', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('ZOLUMHX', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('VO4MLK2', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('2XTXUDI', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('GVLVNBD', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('U8UT6U7', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('K0X57PW', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('TT3TZQC', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('T8W4EBU', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('X0O59XN', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('89TFFMZ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('77BP57L', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('NL2BOX4', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('K1R1WS8', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('PAZVT5Y', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('EPH4C9I', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('JGJKGAT', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('VF2XZDX', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('37U74RT', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('XJQLHBU', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('X581DWS', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('FXBHFC6', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('PX58AP2', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('YFD7F4S', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('SC8OA7C', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('FJVSH58', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('GYTAMTM', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('T8EBFJ8', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('VU3NB9R', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('PS77YHM', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('VIN6TOC', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('JX9SPE8', 'radar de recul');
INSERT INTO projet.AssocOptions VALUES('1YI2044', 'radar de recul');

INSERT INTO projet.AssocOptions VALUES('YP6IQD8', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('JQUL6IJ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('SE2QLTO', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('GDVH2T4', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('MLF08ET', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('PPHS3OQ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('BT4NJXD', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('22VM6BN', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('1SBIWCJ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('L1NP2LI', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('RRXWUIV', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('DRBZ26L', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('IBO3LA2', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('2WIYOH5', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('0JFLC1Y', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('4FPK7VW', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('3FS1I81', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('LWJM412', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('XUDQWPF', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('BXAQQ5I', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('LVH0Q7M', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('V3E8WWW', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('WFLVNG5', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('I5OAZ78', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('N0I8J2I', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('RHUB7FW', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('KCDJUHU', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('2LLCLWU', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('55HMZCX', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('SM2SXQZ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('ME45Q7Q', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('DYAI4EJ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('5NJRHF6', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('22MQGQ0', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('8OBST8R', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('2HAYQGU', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('NKP0CGQ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('QGXF6JH', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('MWKAVL7', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('4SZZSKP', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('D6RWH3W', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('L0ISBTF', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('Y4RCQ7K', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('Y2SJQDL', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('GL19SG0', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('K2ZRMT9', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('2DNCD8R', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('6L7INEF', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('ZOLUMHX', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('VO4MLK2', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('2XTXUDI', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('GVLVNBD', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('U8UT6U7', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('K0X57PW', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('TT3TZQC', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('T8W4EBU', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('X0O59XN', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('89TFFMZ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('77BP57L', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('NL2BOX4', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('K1R1WS8', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('PAZVT5Y', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('EPH4C9I', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('JGJKGAT', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('VF2XZDX', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('37U74RT', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('XJQLHBU', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('X581DWS', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('FXBHFC6', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('PX58AP2', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('YFD7F4S', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('SC8OA7C', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('FJVSH58', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('GYTAMTM', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('T8EBFJ8', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('VU3NB9R', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('PS77YHM', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('VIN6TOC', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('JX9SPE8', 'autoradio tactile');
INSERT INTO projet.AssocOptions VALUES('1YI2044', 'autoradio tactile');

INSERT INTO projet.AssocOptions VALUES('YP6IQD8', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('JQUL6IJ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('SE2QLTO', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('GDVH2T4', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('MLF08ET', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('PPHS3OQ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('BT4NJXD', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('22VM6BN', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('1SBIWCJ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('L1NP2LI', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('RRXWUIV', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('DRBZ26L', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('IBO3LA2', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('2WIYOH5', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('0JFLC1Y', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('4FPK7VW', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('3FS1I81', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('LWJM412', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('XUDQWPF', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('BXAQQ5I', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('LVH0Q7M', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('V3E8WWW', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('WFLVNG5', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('I5OAZ78', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('N0I8J2I', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('RHUB7FW', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('KCDJUHU', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('2LLCLWU', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('55HMZCX', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('SM2SXQZ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('ME45Q7Q', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('DYAI4EJ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('5NJRHF6', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('22MQGQ0', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('8OBST8R', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('2HAYQGU', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('NKP0CGQ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('QGXF6JH', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('MWKAVL7', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('4SZZSKP', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('D6RWH3W', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('L0ISBTF', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('Y4RCQ7K', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('Y2SJQDL', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('GL19SG0', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('K2ZRMT9', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('2DNCD8R', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('6L7INEF', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('ZOLUMHX', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('VO4MLK2', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('2XTXUDI', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('GVLVNBD', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('U8UT6U7', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('K0X57PW', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('TT3TZQC', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('T8W4EBU', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('X0O59XN', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('89TFFMZ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('77BP57L', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('NL2BOX4', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('K1R1WS8', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('PAZVT5Y', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('EPH4C9I', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('JGJKGAT', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('VF2XZDX', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('37U74RT', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('XJQLHBU', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('X581DWS', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('FXBHFC6', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('PX58AP2', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('YFD7F4S', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('SC8OA7C', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('FJVSH58', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('GYTAMTM', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('T8EBFJ8', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('VU3NB9R', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('PS77YHM', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('VIN6TOC', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('JX9SPE8', 'lecteurs DVD');
INSERT INTO projet.AssocOptions VALUES('1YI2044', 'lecteurs DVD');

INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'toit panoramique');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'toit panoramique');

INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'vitres teintees');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'vitres teintees');

INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'GPS');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'GPS');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'GPS');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'GPS');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'GPS');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'GPS');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'GPS');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'GPS');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'GPS');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'GPS');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'GPS');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'GPS');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'GPS');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'GPS');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'GPS');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'GPS');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'GPS');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'GPS');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'GPS');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'GPS');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'GPS');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'GPS');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'GPS');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'GPS');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'GPS');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'GPS');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'GPS');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'GPS');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'GPS');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'GPS');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'GPS');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'GPS');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'GPS');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'GPS');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'GPS');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'GPS');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'GPS');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'GPS');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'GPS');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'GPS');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'GPS');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'GPS');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'GPS');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'GPS');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'GPS');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'GPS');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'GPS');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'GPS');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'GPS');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'GPS');

INSERT INTO projet.AssocOptions VALUES('9GT42QJ', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('8253Y3Z', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('SZKXIY9', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('NJ9L6FP', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('2B7EABE', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('WKUU8CQ', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('0CURA9S', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('NNCLA0K', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('MY6EVLB', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('FDCTZX1', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('V62MHCL', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('YDCKJIU', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('9NBKIFC', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('6M89JH4', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('SS4GH0X', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('VE65M59', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('YQSV1KD', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('XACZKOB', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('IZMU4DI', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('RTPX4KO', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('V7ZBV5W', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('FRIW5RF', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('YUR9GNB', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('ZBKTSXH', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('4C7PSPI', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('RBQSPVS', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('N44ZDR7', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('BUPKDTG', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('1P2728G', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('ZRIE4GS', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('4FK0HHH', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('NCWGVYS', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('YLDHKTX', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('UVDLYL0', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('9SESKEL', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('5JWWRUH', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('PZG0LB0', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('9VT8Q3L', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('YAM21OQ', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('VMJP8LV', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('T3P0ZEA', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('O2N7BKR', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('BL7IMIN', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('6ZV8W97', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('GB579LW', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('K87DITE', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('7ZXD5HK', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('UXPE8MN', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('SD2EUNC', 'sieges chauffants');
INSERT INTO projet.AssocOptions VALUES('6V58398', 'sieges chauffants');

/* TABLE ClientProfessionnel */
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 1,'Aris Technologies', 'Fournisseur systeme de surveillance');
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 2,'Dubois SAS', 'Fournisseur materiel frigorifique');
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 3,'Euroflaco', NULL);
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 4,'CHICN', 'Hopitaux et cliniques');
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 5,'La Diligence', 'Hotellerie, restauration et tourisme');
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 6,'Straco', NULL);
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 7,'Taxis Daras', NULL);
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 8,'Barriquand',NULL);
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 9,'ACP', NULL);
INSERT INTO projet.ClientProfessionnel VALUES(nextval('seq_idClientProfessionnel'), 10,'CTAC', NULL);

/* TABLE ClientParticulier */
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '5182514127', 'Hutte' , 'Sacha', NULL, '068763226587', '1987-04-20');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '0809328454', 'Kiroul' , 'Pierre', '23 rue Michel Ange', '0196058086', '1974-10-13');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '7424232377', 'Giguere', 'Slainie', '58 rue Nationale', '0124235871', '1952-09-10');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '0157536702', 'Lebatelier', 'Fantina', '32 rue du Clair Blocage', '0640801868', '1996-01-26');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '8337252855', 'Faubert', 'Anouk', NULL, '0649040789', '1962-05-05');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '1818406652', 'Devost', 'Mercer', '92 rue Bonneterie', '0610361083', '1974-03-29');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '5558384041', 'Douffet', 'Soren', '23 rue de Raymond Poincare', '0696685383', '1994-12-05');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '2996396509', 'Artois', 'Pascaline', '27 rue Nationale', '0632964538', '1956-04-02');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '7536502833', 'Devost', 'Mercer', '92 rue Bonneterie', '0610361083', '1974-03-29');
INSERT INTO projet.ClientParticulier VALUES(nextval('seq_idClientParticulier'), '6084353306', 'Laderoute', 'Mathieu', NULL, '0653395057', '1997-09-24');

/* TABLE Conducteur */
INSERT INTO projet.Conducteur VALUES(2703172413, 'Oin', 'Serge', NULL, '0653395057', '1988-01-10',2);
INSERT INTO projet.Conducteur VALUES(3705231740, 'To', 'Marc', NULL, '0632025392', '1970-01-28',2);
INSERT INTO projet.Conducteur VALUES(0334874153, 'Beaule', 'Henri', '63 avenue des tuileries', '0689280963', '19630601', 2);
INSERT INTO projet.Conducteur VALUES(6994987445, 'Proulx', 'Anne', '74 rue du chateau', '0617504883', '1997-01-14',2);
INSERT INTO projet.Conducteur VALUES(0495934726, 'Gosselin', 'Margot', NULL, '0626731995', '1983-09-24',2);
INSERT INTO projet.Conducteur VALUES(1998399610, 'Rochon', 'Yseult', NULL, '0449389201', '1978-01-12',2);
INSERT INTO projet.Conducteur VALUES(4442190097, 'Goudreau', 'Julie', '47 rue frederic chopin', '0678586577', '1980-06-24',2);
INSERT INTO projet.Conducteur VALUES(3553033426, 'Briard', 'Clement', NULL, '0618715233', '1965-07-07', 2);
INSERT INTO projet.Conducteur VALUES(2501453344, 'Busson', 'Victor', NULL, '0671971311', '1984-02-02',4);
INSERT INTO projet.Conducteur VALUES(7407653690, 'Hugues', 'Isabelle', '60 rue porte orange', '0602598427', '1986-01-08',4);
INSERT INTO projet.Conducteur VALUES(2558515831, 'Carignan', 'Pauline', NULL, '0699036833', '1994-02-19',4);
INSERT INTO projet.Conducteur VALUES(7275640744, 'Veilleux', 'Amelie', NULL, '0670730349', '1970-08-07', 4);
INSERT INTO projet.Conducteur VALUES(2938328296, 'Labossiere', 'Edith', '89 rue des soeurs', '0683319998', '1980-03-31',4);
INSERT INTO projet.Conducteur VALUES(3903029899, 'Beausoleil', 'Nicolas', NULL, '0608640493', '1967-05-15', 4);
INSERT INTO projet.Conducteur VALUES(9273166831, 'Cantin', 'Prunella', NULL, '0619079541', '1988-10-03',4);

/* TABLE SocieteEntretien */
INSERT INTO projet.SocieteEntretien VALUES(DEFAULT, 'Speedy', 'Rent A Car Compiegne');
INSERT INTO projet.SocieteEntretien VALUES(DEFAULT, 'Midas', 'Rent A Car Compiegne');
INSERT INTO projet.SocieteEntretien VALUES(DEFAULT, 'Avatacar', 'Rent A Car Compiegne');
INSERT INTO projet.SocieteEntretien VALUES(DEFAULT, 'Park Net Auto', 'Rent A Car Compiegne');
INSERT INTO projet.SocieteEntretien VALUES(DEFAULT, 'Euromaster', 'Rent A Car Compiegne');

/* TABLE Entretien */
insert into projet.Entretien values(DEFAULT, '2021-05-30', NULL, 10634353);
insert into projet.Entretien values(DEFAULT, '2021-05-19', 1, NULL);
insert into projet.Entretien values(DEFAULT, '2021-05-02', NULL, 29243556);
insert into projet.Entretien values(DEFAULT, '2021-05-18', 1, NULL);

/* TABLE Facturation */
insert into projet.Facturation values (DEFAULT, NULL, NULL, NULL, 16001022);
insert into projet.Facturation values (DEFAULT, NULL, NULL, NULL, 29321328);
insert into projet.Facturation values (DEFAULT, NULL, NULL, NULL, 24242429);
insert into projet.Facturation values (DEFAULT, '2021-06-25', 'cheque', 201, 29321328);
insert into projet.Facturation values (DEFAULT, '2021-06-15', 'especes', 192, 15065724);
insert into projet.Facturation values (DEFAULT, '2021-06-25', 'CB', 225, 11824521);
insert into projet.Facturation values (DEFAULT, '2021-06-28', 'cheque', 250, 29552327);
insert into projet.Facturation values (DEFAULT, '2021-06-15', 'CB', 192, 13324025);
INSERT INTO projet.Facturation values (DEFAULT, '2021-06-30', 'CB', 225, 16001022);

/* TABLE ContratLocation */
insert into projet.ContratLocation values(DEFAULT, '2021-02-18', '10:00:00', '11:00:00', '2021-04-18', '2021-04-20', 30, 'XACZKOB', 16001022, 1, NULL);
insert into projet.ContratLocation values(DEFAULT, '2021-02-27', '09:00:00', '11:00:00', '2021-04-27', '2021-04-28', 45, 'VO4MLK2', 29321328, 2, NULL);
insert into projet.ContratLocation values(DEFAULT, '2021-02-26', '10:00:00', '11:00:00', '2021-04-26', '2021-04-29', 66, 'V7ZBV5W', 24242429, 3, NULL);
insert into projet.ContratLocation values(DEFAULT, '2021-02-11', '10:00:00', '11:00:00', '2021-03-11', '2021-03-11', 67, '9NBKIFC', 29321328, 4, 1);
insert into projet.ContratLocation values(DEFAULT, '2021-02-11', '10:00:00', '11:00:00', '2021-03-11', '2021-03-12', 55, '0CURA9S', 15065724, 5, 2);
insert into projet.ContratLocation values(DEFAULT, '2021-02-20', '10:00:00', '11:00:00', '2021-04-20', '2021-04-20', 50, '6M89JH4', 11824521, 6, NULL);
insert into projet.ContratLocation values(DEFAULT, '2021-02-20', '10:00:00', '11:00:00', '2021-03-20', '2021-03-20', 35, 'FRIW5RF', 29552327, 7, 3);
insert into projet.ContratLocation values(DEFAULT, '2021-02-05', '10:00:00', '12:00:00', '2021-04-06', '2021-04-06', 55, '0CURA9S', 13324025, 8, 4);
	/* tarif + if(km>=100) (km-100) * 0.5*tarif */

/* TABLE ContratParticulier */
insert into projet.ContratParticulier values (1, 1);
insert into projet.ContratParticulier values (2, 5);
insert into projet.ContratParticulier values (4, 3);
insert into projet.ContratParticulier values (5, 3);
insert into projet.ContratParticulier values (6, 1);

/* TABLE ContratProfessionnel */
insert into projet.ContratProfessionnel values (3, 6994987445);
insert into projet.ContratProfessionnel values (7, 7275640744);
insert into projet.ContratProfessionnel values (8, 2703172413);


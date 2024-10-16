CREATE SCHEMA nosql;


/*Agent Technique*/
CREATE TABLE nosql.AgentTechnique (
  numsecusociale INTEGER PRIMARY KEY,
  nom VARCHAR NOT NULL,
  prenom VARCHAR NOT NULL,
  dateNaissance DATE NOT NULL,
  agence JSON NOT NULL
);

INSERT INTO AgentTechnique VALUES ( 1, 'Delareine', 'Jean', '1970-01-08','{"nom": "Rent A Car Compiègne"}');
INSERT INTO AgentTechnique VALUES ( 2, 'Simon', 'Lucas', '1992-10-13','{"nom": "Rent A Car Compiègne"}');
INSERT INTO AgentTechnique VALUES ( 3, 'Michel', 'Adam', '1992-12-29','{"nom": "Rent A Car Compiègne"}');
INSERT INTO AgentTechnique VALUES ( 4, 'Lefèvre', 'Jules', '1993-02-12','{"nom": "Rent A Car Compiègne"}');


/* Facturation */

CREATE TABLE nosql.Facturation (
	idFact SERIAL PRIMARY KEY,
	dateFacturation DATE,
	moyenReglement VARCHAR CHECK (moyenReglement='CB' OR moyenReglement='cheque'
		OR moyenReglement='especes' OR moyenReglement='virement'),
	montant FLOAT(8),
	agentCommercial JSON NOT NULL
);

INSERT INTO nosql.Facturation VALUES(DEFAULT, '2021-06-05', 'CB', '400' ,
'{"numsecusocial":11824521,"nom":"Martin","prenom":"Gabriel","dateNaissance":"1986-09-20","agence":"Rent A Car Compiègne"}' );

INSERT INTO nosql.Facturation VALUES(DEFAULT, '2021-05-20', 'virement', '410' ,
'{"numsecusocial":11824521,"nom":"Martin","prenom":"Gabriel","dateNaissance":"1986-09-20","agence":"Rent A Car Compiègne"}' );

INSERT INTO nosql.Facturation VALUES(DEFAULT, '2021-06-10', 'virement', '100' ,
'{"numsecusocial":16001022,"nom":"Bernard","prenom":"Leo","dateNaissance":"1987-07-26","agence":"Rent A Car Compiègne"}' );

INSERT INTO nosql.Facturation VALUES(DEFAULT, '2021-06-01', 'CB', '300',
'{"numsecusocial":18525423,"nom":"Thomas","prenom":"Raphael","dateNaissance":"1988-11-04","agence":"Rent A Car Compiègne"}' );

/*Véhicule*/


CREATE TABLE nosql.R2(
    idR2 INTEGER PRIMARY KEY,
    nomModele JSON,
    km INTEGER,
    tarif INTEGER NOT NULL
);

INSERT INTO  nosql.R2 VALUES(
1, '{"nomModele" : "Clio"}', 0, 250
);
INSERT INTO nosql.R2 VALUES(
2, '{"nomModele" : "Captur"}', 0, 209
);
INSERT INTO nosql.R2 VALUES(
  3, '{"nomModele" : "Espace"}', 0, 249
);


CREATE TABLE nosql.Vehicule (
  immat VARCHAR PRIMARY KEY,
  marque VARCHAR NOT NULL,
  couleur VARCHAR NOT NULL,
  idR2 INTEGER NOT NULL,
  FOREIGN KEY(idR2) REFERENCES nosql.R2,
  typeCarburant JSON NOT NULL,
  agence JSON NOT NULL
);


INSERT INTO nosql.Vehicule VALUES('YP6IQD8', 'Renault', 'bleu', 1,
'{"nom":"E5"}',
'{"nom":"Rent A Car Compiègne"}');

INSERT INTO nosql.Vehicule VALUES('9GT42QJ', 'Renault', 'orange', 2,
'{"nom":"E5"}',
'{"nom":"Rent A Car Compiègne"}');

INSERT INTO nosql.Vehicule VALUES('RRXWUIV', 'Ford', 'blanc', 3,
'{"nom":"XTL"}',
'{"nom":"Rent A Car Compiègne"}');




CREATE TABLE  nosql.ClientProfessionnel (
idClient INTEGER PRIMARY KEY,
idEntreprise INTEGER,
nom TEXT,
infosEntreprise TEXT,
conducteurs JSON
);


INSERT INTO nosql.ClientProfessionnel
VALUES (
  1,
  1,
'Car Location',
'Car Location est une entreprise de location de voiture depuis 2011',
'[{"numeropermis":"1", "nom" : "Dupont", "prenom" : "Arthur", "numeroTel" : "062030405060", "dateNaissance" : "1990-05-20"},
{"numeropermis":"3", "nom" : "Lacombe", "prenom" : "Apolline", "numeroTel" : "0426994294", "dateNaissance" : "1986-08-30"},
{"numeropermis":"4", "nom" : "Moquin", "prenom" : "André", "numeroTel" : "0419160431", "dateNaissance" : "1973-09-17"}]'
);

CREATE TABLE nosql.ContratLocation (
    idContrat SERIAL PRIMARY KEY,
    dateReservation DATE  NOT NULL,
    heureDebut TIME  NOT NULL,
    heureFin TIME NOT NULL,
    dateDebutLocation DATE  NOT NULL,
    dateFinLocation DATE  NOT NULL,
    kilometrage INTEGER,
    vehicule VARCHAR NOT NULL,
    agent JSON,
    facturation INTEGER NOT NULL,
    entretien JSON UNIQUE,
    FOREIGN KEY(vehicule) REFERENCES projet.Vehicule(immat),
    FOREIGN KEY(facturation) REFERENCES projet.Facturation(idFact),
    CONSTRAINT check_date CHECK((DateDebutLocation < DateFinLocation)
      OR (DateDebutLocation = DateFinLocation AND heureDebut < heureFin))
    /* dateFinLocation < dateEntretien */
);

insert into nosql.ContratLocation values(
    DEFAULT,
    '2021-02-11',
    '10:00:00',
    '11:00:00',
    '2021-03-11',
    '2021-03-11',
    67,
    'YP6IQD8',
    '{"numsecusocial":11824521,"nom":"Martin","prenom":"Gabriel","dateNaissance":"1986-09-20","agence":"Rent A Car Compiègne"}',
    1,
    '{"numeroEntretien" : 1, "dateEntretien" : "2021-05-30", "societeEntretien" : "NULL", "agentTechnique" : "10634353"}'
);

insert into nosql.ContratLocation values(
    DEFAULT,
    '2021-02-20',
    '10:00:00',
    '11:00:00',
    '2021-03-20',
    '2021-03-20',
    35,
    '9GT42QJ',
    '{"numsecusocial":11824521,"nom":"Martin","prenom":"Gabriel","dateNaissance":"1986-09-20","agence":"Rent A Car Compiègne"}',
    2,
    '{"numeroEntretien" : 2, "dateEntretien" : "2021-05-02", "societeEntretien" : 1, "agentTechnique" : 29243556}'
);

insert into nosql.ContratLocation values(
    DEFAULT,
    '2021-02-05',
    '10:00:00',
    '12:00:00',
    '2021-04-06',
    '2021-04-06',
    55,
    'RRXWUIV',
    '{"numsecusocial":11824521,"nom":"Martin","prenom":"Gabriel","dateNaissance":"1986-09-20","agence":"Rent A Car Compiègne"}',
    3,
    '{"numeroEntretien" : 3, "dateEntretien" : "2021-05-18", "societeEntretien" : NULL, "agentTechnique" : 29243556}
);
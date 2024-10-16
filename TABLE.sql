/*    FICHIER DE CREATION DES TABLES    */

/* Membres du groupe :
  * Anaïs Laveau
  * Thomas Leymonerie
  * Jose Eduardo Garcia Beltran
  * Paul-Edouard Margerit
*/
CREATE SCHEMA projet;

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
	agentCommercial INTEGER,
	FOREIGN KEY(agentCommercial) REFERENCES projet.AgentCommercial(numSecuSociale)
);

CREATE TABLE projet.ClientProfessionnel (
  idCLient SERIAL PRIMARY KEY,
  idEntreprise SERIAL,
  nom VARCHAR NOT NULL,
  infosEntreprise VARCHAR
);

CREATE TABLE projet.ClientParticulier (
  idClient SERIAL PRIMARY KEY,
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

/*    FICHIER DES REQUETES    */

/* Membres du groupe :
  * Anaïs Laveau
  * Thomas Leymonerie
  * Jose Eduardo Garcia Beltran
  * Paul-Edouard Margerit
*/


/* Tous les véhicules dispo qui ont un GPS  */
SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule
    INNER JOIN projet.AssocOptions ON Vehicule.immat = AssocOptions.vehicule
    LEFT JOIN projet.ContratLocation ON  projet.Vehicule.immat = projet.ContratLocation.vehicule
    WHERE (projet.ContratLocation.vehicule IS NULL OR projet.ContratLocation.entretien IS NOT NULL) AND projet.AssocOptions.option = 'GPS';

/* Tous les véhicules qui doivent être entretenus */ 
SELECT projet.vehicule.* FROM projet.vehicule INNER JOIN projet.contratlocation ON projet.vehicule.immat = projet.contratlocation.vehicule WHERE projet.contratlocation.entretien IS NULL AND projet.contratlocation.datefinlocation IS NOT NULL;

/* Tous les contrats qui n'ont pas été payés */
SELECT projet.ContratLocation.* FROM projet.ContratLocation, Facturation WHERE projet.ContratLocation.Facturation = projet.Facturation.idfact AND projet.Facturation.datefacturation IS NULL;

/* Tous les véhicules disponibles */
SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule
    LEFT JOIN projet.ContratLocation ON  projet.Vehicule.immat = projet.ContratLocation.vehicule WHERE (projet.ContratLocation.vehicule IS NULL OR projet.ContratLocation.entretien IS NOT NULL) AND projet.vehicule.agence='Rent A Car Compiegne';

/* Toutes les locations d'un agent d'un certain mois */
SELECT projet.ContratLocation.* FROM projet.ContratLocation, projet.AgentCommercial WHERE projet.ContratLocation.agent = projet.AgentCommercial.numsecusociale AND projet.ContratLocation.dateReservation < to_date('2021-05-00', 'YYYY-MM-DD') AND projet.ContratLocation.dateReservation >= to_date('2021-04-00', 'YYYY-MM-DD')

/* Tous les conducteurs d'une agence X(Example X='1001') */
SELECT projet.Conducteur.* FROM projet.Conducteur INNER JOIN projet.ClientProfessionnel ON projet.Conducteur.clientProfessionnel = projet.ClientProfessionnel.idEntreprise AND projet.ClientProfessionnel.idEntreprise = '1'

/* Tous les véhicules disponibles qui sont de la catégorie 'citadine' */
SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule
    INNER JOIN projet.Modele ON projet.Vehicule.nomModele = projet.Modele.nomModele
    INNER JOIN projet.CategorieVehicule ON projet.CategorieVehicule.nom = projet.Modele.categorie
    LEFT JOIN projet.ContratLocation ON  projet.Vehicule.immat = projet.ContratLocation.vehicule WHERE (projet.ContratLocation.vehicule IS NULL) AND projet.CategorieVehicule.nom = 'citadine';

/* Tous les véhicules disponibles à un certain intervalle des tarifs */
SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule
    LEFT JOIN projet.ContratLocation ON  projet.Vehicule.immat = projet.ContratLocation.vehicule
    WHERE (projet.ContratLocation.vehicule IS NULL OR projet.ContratLocation.entretien IS NOT NULL) AND projet.Vehicule.tarif > 200 AND projet.Vehicule.tarif < 225;

/* Bilan financier par entreprise et par particulier */
SELECT projet.ClientProfessionnel.nom, COUNT(projet.Facturation.idFact), SUM(projet.Facturation.montant) 
	FROM projet.ClientProfessionnel, projet.Facturation, projet.ContratLocation, projet.Conducteur, projet.ContratProfessionnel
	WHERE projet.ContratLocation.facturation = projet.Facturation.idFact
	AND projet.ContratProfessionnel.conducteur = projet.Conducteur.numeroPermis
	AND projet.ContratLocation.idContrat = projet.ContratProfessionnel.idContrat
	AND projet.Conducteur.clientProfessionnel = projet.ClientProfessionnel.idClient	
	AND projet.Facturation.montant IS NOT NULL
	GROUP BY projet.ClientProfessionnel.nom;

SELECT projet.ClientParticulier.nom, projet.ClientParticulier.prenom, COUNT(projet.Facturation.idFact), SUM(projet.Facturation.montant)
	FROM projet.ClientParticulier, projet.ContratParticulier, projet.Facturation, projet.ContratLocation
	WHERE projet.ContratLocation.facturation = projet.Facturation.idFact
	AND projet.ContratLocation.idContrat = projet.ContratParticulier.idContrat
	AND projet.ContratParticulier.clientParticulier = projet.ClientParticulier.idClient 
	AND projet.Facturation.montant IS NOT NULL
	GROUP BY projet.ClientParticulier.prenom, projet.ClientParticulier.nom;

/* Tous les noms des conducteurs rangés alphabétiquement et leur clientProfessionnel associé */
SELECT projet.Conducteur.nom, projet.ClientProfessionnel.nom FROM projet.Conducteur, projet.ClientProfessionnel
	WHERE projet.ClientProfessionnel.idClient = projet.Conducteur.clientProfessionnel
	ORDER BY projet.Conducteur.nom;

/* Le nombre de vehicule rouge */
SELECT COUNT(*) FROM projet.Vehicule WHERE projet.Vehicule.couleur = 'rouge'

/* Le nombre de vehicule qui doivent être entretenu*/
SELECT COUNT(*) FROM projet.ContratLocation WHERE projet.ContratLocation.entretien IS NULL

/* Tous les véhicules classés par ordre croissant de prix qui sont disponibles */
SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule, projet.ContratLocation WHERE projet.ContratLocation.entretien IS NOT NULL ORDER BY projet.Vehicule.tarif

/* Tous les véhicules classés par ordre croissant de prix qui ont un GPS qui sont disponnibles*/
SELECT DISTINCT Vehicule.* FROM Vehicule, ContratLocation, AssocOptions WHERE Vehicule.immat = AssocOptions.vehicule and AssocOptions.option = 'GPS' and (ContratLocation.vehicule is NOT NULL or ContratLocation.entretien IS NOT NULL) ORDER BY Vehicule.tarif 
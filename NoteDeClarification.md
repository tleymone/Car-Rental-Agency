<<<<<<< HEAD
#Note De Clarification
    Une agence de location de véhicules souhaite se doter d'un logiciel lui permettant de gérer son système d'information.
    Les personnes qui seront amenées à manipuler cette base de données sont, soit les agents(Techniques ou Commerciaux), soit les clients.
    Plus précisément, un agent possède des droits, ajout d’un compte d’un client et supprime d’un compte d’un client, gestion de locations et du parc véhiculaire, le client possède des droits de lecture des locations qu’il a effectué, et des droits des gestion d’une location à effectuer ou d’une location actuelle.
    Ce document constitue une reformulation du cahier des charges et les informations sont ordonnées de telle sorte à ce que l’implémentation de la base de données soit la plus logique possible.

##La gestion des locations
    L’agence est composée par des agents commerciaux et des agents techniques.
    Chaque location donne lieu à̀ un Contrat de Location (signé par le client), et elle est associée à un seul véhicule. Les contrats de location sont gérés par les agents commerciaux.
    Le Contrat de Location signale, le nombre de kilomètres parcourus par le véhicule.
    La facturation concerne un seul client, et est associée à une ou plusieurs locations.
    Au départ de la location, le client doit présenter à l'agence une carte bancaire.
    La validation finale d'une location est effectuée par un agent commercial (vérification des conditions).
    Quand une facture est payée, nous inscrivons le montant, la date et le moyen de règlement.
    Un agent commercial gère les locations et édite les factures ;
    Un agent technique gère le parc automobile et le processus d'entretien ;
    L'agence fait appel à̀ des sociétés d'entretien.
###Hypothèses :
    Un historique des contrats est garde, et il faut que le contrat précèdent soit terminer avant de louer à nouveau un même véhicule.

##Les clients
    Un client a la possibilité́ d'ajouter, annuler, modifier ou valider une location.
    Un conducteur (soit particulier ou soit partie de l’ensembles des conducteurs d’un client professionnel) doit avoir un âge minimum de 21 ans.
    Il y a deux types de clients, le client particulier (conducteur) qui doit fournir plusieurs informations personnelles : nom, prénom, adresse, Age, numéro de téléphone et numéro de permis, et le client professionnel qui doit fournir des informations sur l'entreprise, ainsi que la liste de leurs conducteurs et les numéros de leur permis.
###Hypothèses :
    La liste des conducteurs d’un client professionnel est composée par conducteur qui peuvent avoir des contrats de location particuliers.
    Il existe un unique contrat par conducteur au cas d’un client professionnel, qui peut signer plusieurs contrats pour différents conducteurs et dans le cas d’un client particulier, il peut signer qu’un seul contrat à # fois.

##La gestion des véhicules
    L’agence propose ses véhicules avec un tarif, pour chaque durée de location il y a un seuil de kilométrage fixé à 100 Km. Si le client dépasse ce seuil, le kilomètre est facturé x€.
    Pour un véhicule, on a comme clé primaire un numéro d’immatriculation, un couleur, un tarif et le nombre de kilomètres parcouru.
    Un véhicule peut-être d’un modèle caractérisé par un nombre des portes. Tous les véhicules d'un modèle donné sont forcément toujours de la même catégorie.
    Un véhicule est classe dans les catégories suivantes : citadine, berline petite, berline moyenne, berline grande, 4X4 SUV, break , pickup, utilitaire.
    Un modèle d’un véhicule est propre d’une marque.
    Tout véhicule fonction avec un type carburant (gasoil, sans plomb95, sans plomb98, …) et a des différentes options (GPS, AC, ...).
    Un véhicule est contrôlé lors de son retour après une location. Ce contrôle est effectué́ par un agent technique ou par une société d'entretien (un des deux, pas le deux au même temps).
###Hypothèses:
=======
# Note De Clarification
* Une agence de location de véhicules souhaite se doter d'un logiciel lui permettant de gérer son système d'information.
* Les personnes qui seront amenées à manipuler cette base de données sont, soit les agents(Techniques ou Commerciaux), soit les clients.
* Plus précisément, un agent possède des droits, ajout d’un compte d’un client et supprime d’un compte d’un client, gestion de locations et du parc véhiculaire, le client possède des droits de lecture des locations qu’il a effectué, et des droits des gestion d’une location à effectuer ou d’une location actuelle.
* Ce document constitue une reformulation du cahier des charges et les informations sont ordonnées de telle sorte à ce que l’implémentation de la base de données soit la plus logique possible.

## La gestion des locations
* L’agence est composée par des agents commerciaux et des agents techniques.
* Chaque location donne lieu à̀ un Contrat de Location (signé par le client), et elle est associée à un seul véhicule. Les contrats de location sont gérés par les agents commerciaux.
* Le Contrat de Location signale, le nombre de kilomètres parcourus par le véhicule.
* La facturation concerne un seul client, et est associée à une ou plusieurs locations.
* Au départ de la location, le client doit présenter à l'agence une carte bancaire.
* La validation finale d'une location est effectuée par un agent commercial (vérification des conditions).
* Quand une facture est payée, nous inscrivons le montant, la date et le moyen de règlement.
* Un agent commercial gère les locations et édite les factures ;
* Un agent technique gère le parc automobile et le processus d'entretien ;
* L'agence fait appel à̀ des sociétés d'entretien.
### Hypothèses :
* Un historique des contrats est garde, et il faut que le contrat précèdent soit terminer avant de louer à nouveau un même véhicule.

## Les clients
* Un client a la possibilité́ d'ajouter, annuler, modifier ou valider une location.
* Un conducteur (soit particulier ou soit partie de l’ensembles des conducteurs d’un client professionnel) doit avoir un âge minimum de 21 ans.
* Il y a deux types de clients, le client particulier (conducteur) qui doit fournir plusieurs informations personnelles : nom, prénom, adresse, Age, numéro de téléphone et numéro de permis, et le client professionnel qui doit fournir des informations sur l'entreprise, ainsi que la liste de leurs conducteurs et les numéros de leur permis.
### Hypothèses :
* La liste des conducteurs d’un client professionnel est composée par conducteur qui peuvent avoir des contrats de location particuliers.
* Il existe un unique contrat par conducteur au cas d’un client professionnel, qui peut signer plusieurs contrats pour différents conducteurs et dans le cas d’un client particulier, il peut signer qu’un seul contrat à la fois.

## La gestion des véhicules
* L’agence propose ses véhicules avec un tarif, pour chaque durée de location il y a un seuil de kilométrage fixé à 100 Km. Si le client dépasse ce seuil, le kilomètre est facturé x€.
* Pour un véhicule, on a comme clé primaire un numéro d’immatriculation, un couleur, un tarif et le nombre de kilomètres parcouru.
* Un véhicule peut-être d’un modèle caractérisé par un nombre des portes. Tous les véhicules d'un modèle donné sont forcément toujours de la même catégorie.
* Un véhicule est classe dans les catégories suivantes : citadine, berline petite, berline moyenne, berline grande, 4X4 SUV, break , pickup, utilitaire.
* Un modèle d’un véhicule est propre d’une marque.
* Tout véhicule fonction avec un type carburant (gasoil, sans plomb95, sans plomb98, …) et a des différentes options (GPS, AC, ...).
* Un véhicule est contrôlé lors de son retour après une location. Ce contrôle est effectué́ par un agent technique ou par une société d'entretien (un des deux, pas le deux au même temps).
### Hypothèses:
>>>>>>> 57ed8b5be7e3a4f61bd9a6dec695a04d282343af

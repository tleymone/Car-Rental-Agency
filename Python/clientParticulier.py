from time import sleep
from datetime import datetime
import connexion


def menu_client_part():
    connexion.screen_clear()

    while True:
        print("\n\t--- Que voulez-vous faire ? ---")
        print("\n\t0.\tRevenir au menu principal")
        print("\n\t1.\tS'inscrire")
        print("\n\t2.\tLouer une voiture")
        print("\n\t3.\tModifier les informations personnelles d'un client particulier")

        choice = connexion.saisie_nb(0,3)
        
        if(choice == 0):
            connexion.screen_clear()
            break
        elif(choice == 1):
            connexion.screen_clear()
            inscrire_client_part()
        elif(choice == 2):
            connexion.screen_clear()
            louer_voiture()
        elif(choice == 3):
            connexion.screen_clear()
            modif_client_part()
        

def inscrire_client_part():
    print("--- Veuillez rentrer les informations suivantes ---\n")
    
    # il faudrait vérifier le format des entrées
    # hypothèse : l'utilisateur rentre des données correctes

    # ClientParticulier.idClient XOR ClientProfessionel.idClient 
    #    -> cf lignes 5 à 8 de creation.sql  
    
    numeroPermis = input("Numéro de permis : ")
    while not numeroPermis or len(numeroPermis)!=10:
        numeroPermis = input("Numéro de permis : ")
            
    nom = input("Nom : ")
    while not nom:
        nom = input("Nom : ")

    prenom = input("Prénom : ")
    while not prenom:
        prenom = input("Prénom : ")

    try:
        adresse = input("Adresse (facultatif) : ")
    except:
        adresse = "NULL"

    numeroTel = input("Numéro de téléphone : ")
    while not numeroTel or len(numeroPermis)!=10:
        numeroTel = input("Numéro de téléphone : ")

    dateNaissance = input("Date de naissance (YYYY-MM-DD): ")
    while not dateNaissance:
        dateNaissance = input("Date de naissance : ")

    connexion.requete("INSERT INTO projet.ClientParticulier VALUES (nextval('seq_idClientParticulier'), '%s', '%s', '%s', '%s', '%s', '%s')" %
    (numeroPermis, nom, prenom, adresse, numeroTel, dateNaissance))



def louer_voiture():
    print("--- Veuillez rentrer les informations suivantes ---\n")

    numeroPermis = input("Numéro de permis : ")
    check = connexion.requete("SELECT idClient FROM projet.ClientParticulier WHERE numeroPermis='%s'"%(numeroPermis))
    while not numeroPermis or not check:
        numeroPermis = input("Numéro de permis : ")
        check = connexion.requete("SELECT idClient FROM projet.ClientParticulier WHERE numeroPermis='%s'"%(numeroPermis))

    idClientPart = check[0][0]

    dateReservation = datetime.today().strftime('%Y-%m-%d')
    # date du jour

    heureDebut = input("Heure de début (hh:mm:ss): ")
    hour, min, sec = [int(i) for i in heureDebut.split(":")]
    while not heureDebut  :
        print("Erreur lors de la saisie de l'heure")
        heureDebut = input("Heure de début (hh:mm:ss): ")
    
    heureFin = input("Heure de fin (hh:mm:ss): ")
    hour, min, sec = [int(i) for i in heureFin.split(":")]
    while not heureFin  :
        print("Erreur lors de la saisie de l'heure")
        heureFin = input("Heure de fin (hh:mm:ss): ")
    
    dateDebutLocation = input("Date de début de location (YYYY-MM-DD): ")
    _, month, day = [int(i) for i in dateDebutLocation.split("-")]
    while not dateDebutLocation :
        print("Erreur lors de la saisie de la date")
        dateDebutLocation = input("Date de début de location (YYYY-MM-DD): ")
    
    dateFinLocation = input("Date de fin de location (YYYY-MM-DD): ")
    _, month, day = [int(i) for i in dateFinLocation.split("-")]
    while not dateFinLocation :
        print("Erreur lors de la saisie de la date")
        dateFinLocation = input("Date de fin de location (YYYY-MM-DD): ")

    
    kilometrage = input("Kilométrage : ")
    if not kilometrage:
        kilometrage = "NULL"
    
    vehicule = input("Immatricuation du véhicule : ")
    check = connexion.requete("SELECT immat FROM projet.Vehicule WHERE immat='%s'"%(vehicule))
    while not vehicule or not check:
        vehicule = input("Immatricuation du véhicule : ")
        check = connexion.requete("SELECT immat FROM projet.Vehicule WHERE immat='%s'"%(vehicule))
        
    
    agent = input("Numéro de sécurité sociale de l'agent : ")
    if not agent:
        agent = "NULL"

    if agent != "NULL":
        check = connexion.requete("SELECT numSecuSociale FROM projet.AgentCommercial WHERE numSecuSociale='%s'"%(agent))
        while not check:
            agent = input("Numéro de sécurité sociale de l'agent : ")
            check = connexion.requete("SELECT numSecuSociale FROM projet.AgentCommercial WHERE numSecuSociale='%s'"%(agent))       

    facturation = input("Numéro de facturation : ")
    check = connexion.requete("SELECT idFact FROM projet.Facturation WHERE idFact='%s'"%(facturation))
    while not facturation or not check:
        facturation = input("Numéro de facturation : ")
        check = connexion.requete("SELECT idFact FROM projet.Facturation WHERE idFact='%s'"%(facturation))

    
    entretien = input("Numéro d'entretien : ")
    if not entretien:
        entretien = "NULL"

    if entretien != "NULL":
        check = connexion.requete("SELECT numeroEntretien FROM projet.Entretien WHERE numeroEntretien='%s'"%(entretien))
        while not check:
            entretien = input("Numéro d'entretien : ")
            check = connexion.requete("SELECT numeroEntretien FROM projet.Entretien WHERE numeroEntretien='%s'"%(entretien))


    connexion.requete("INSERT INTO projet.ContratLocation VALUES (DEFAULT,'%s','%s','%s','%s','%s',%s,'%s',%s,'%s',%s)"
    %(dateReservation, heureDebut, heureFin, dateDebutLocation, dateFinLocation, kilometrage, vehicule, agent, facturation, entretien))

    
    res = connexion.requete("SELECT idContrat FROM projet.ContratLocation ORDER BY idContrat")
    # dernier tuple ajouté : res[-1][0]

    connexion.requete("INSERT INTO projet.ContratParticulier VALUES('%s', '%s')"%(res[-1][0], idClientPart))
    
    
# sert à modifier les attributs d'un client particulier
def modif_client_part():
    print("\n\t--- Quel attribut voulez-vous modifier ? ---")
    print("\n\t0.\tNom")
    print("\n\t1.\tPrénom")
    print("\n\t2.\tAdresse")
    print("\n\t3.\tNuméro de téléphone")
    print("\n\t4.\tAnnuler")
    
    choix = connexion.saisie_nb(0,4)

    if(choix == 0):
        numeroPermis = input("Quel est votre numéro de permis : ")
        while not numeroPermis or len(numeroPermis)!=10:
            numeroPermis = input("Numéro de permis : ")

        conducteur = connexion.requete("SELECT numeroPermis FROM projet.ClientParticulier WHERE numeroPermis='%s'"%(numeroPermis))
            
        if conducteur:
            nom = input("Nouveau nom : ")
            while not nom:
                nom = input("Nouveau nom : ")
            connexion.requete("UPDATE projet.ClientParticulier SET nom = '%s' WHERE numeroPermis = '%s'"%(nom, conducteur[0][0]))
            sleep(1)
            connexion.screen_clear()
        else:
            print("Erreur dans le numéro de permis...")
            sleep(2)
        
    elif(choix == 1):
        numeroPermis = input("Quel est votre numéro de permis : ")
        while not numeroPermis or len(numeroPermis)!=10:
            numeroPermis = input("Numéro de permis : ")

        conducteur = connexion.requete("SELECT numeroPermis FROM projet.ClientParticulier WHERE numeroPermis='%s'"%(numeroPermis))
            
        if conducteur:
            prenom = input("Nouveau prénom : ")
            while not prenom:
                prenom = input("Nouveau prénom : ")
            connexion.requete("UPDATE projet.ClientParticulier SET prenom = '%s' WHERE numeroPermis = '%s'"%(prenom, conducteur[0][0]))
            sleep(1)
            connexion.screen_clear()
        else:
            print("Erreur dans le numéro de permis...")
            sleep(2)
    elif(choix == 2):
        numeroPermis = input("Quel est votre numéro de permis : ")
        while not numeroPermis or len(numeroPermis)!=10:
            numeroPermis = input("Numéro de permis : ")

        conducteur = connexion.requete("SELECT numeroPermis FROM projet.ClientParticulier WHERE numeroPermis='%s'"%(numeroPermis))
            
        if conducteur:
            ad = input("Nouvelle adresse : ")
            while not ad:
                ad = input("Nouvelle adresse : ")
            connexion.requete("UPDATE projet.ClientParticulier SET adresse = '%s' WHERE numeroPermis = '%s'"%(ad, conducteur[0][0]))
            sleep(1)
            connexion.screen_clear()
        else:
            print("Erreur dans le numéro de permis...")
            sleep(2)
    elif(choix == 3):
        numeroPermis = input("Quel est votre numéro de permis : ")
        while not numeroPermis or len(numeroPermis)!=10:
            numeroPermis = input("Numéro de permis : ")

        conducteur = connexion.requete("SELECT numeroPermis FROM projet.ClientParticulier WHERE numeroPermis='%s'"%(numeroPermis))
            
        if conducteur:
            tel = input("Nouveau numéro de téléphone : ")
            while not tel:
                tel = input("Nouveau numéro de téléphone : ")
            connexion.requete("UPDATE projet.ClientParticulier SET nom = '%s' WHERE numeroTel = '%s'"%(tel, conducteur[0][0]))
            sleep(1)
            connexion.screen_clear()
        else:
            print("Erreur dans le numéro de permis...")
            sleep(2)
    elif(choix==4):
        pass
# -*- coding: utf-8 -*-
"""
Created on Thu May 13 11:23:08 2021

@author: Thomas
"""



import datetime
import connexion

def AffCond(conn, ID):
    ligne = connexion.requete("SELECT * FROM  projet.conducteur WHERE clientprofessionnel = '%s'" % (ID))  #Récupérer la liste des conducteurs
    if ligne:
        print("\nListe des conducteurs : ")
        print("\nN° Permis  Nom   Prénom  Adresse  N° Télephone  Date de Naissance")
        print("-----------------------------------------------------------------")
        for i in range(len(ligne)):
                print(ligne[i][0], "|", ligne[i][1], "|", ligne[i][2], "|", ligne[i][3], "|", ligne[i][4], "|", ligne[i][5])
    else: 
        print("")
        print("Il n'y a pas de conducteurs")

def AjCond(conn, ID):
 #Demander toutes les infos avant d'insérer un nouveau conducteur
    permis = input("\nVeuillez entrer son numéro de permis : ")
    while not permis:
        permis = input("\nVeuillez entrer son numéro de permis : ")
    nom = input("Veuillez entrer son nom : ")
    while not nom:
        nom = input("Veuillez entrer son nom : ")
    prenom = input("Veuillez entrer son prénom : ")
    while not prenom:
        prenom = input("Veuillez entrer son prénom : ")
    adresse = input("Veuillez entrer son adresse : ")
    while not adresse:
        adresse = input("Veuillez entrer son adresse : ")
    numero = input("Veuillez entrer son numéro de télephone : ")
    while not numero:
        numero = input("Veuillez entrer son numéro de télephone : ")
    naiss = input("Veuillez entrer sa date de naissance (DD-MM-YYYY) : ")
    while not naiss:
        naiss = input("Veuillez entrer sa date de naissance (DD-MM-YYYY) : ")
    connexion.requete("INSERT INTO projet.conducteur values ('%s', '%s', '%s', '%s', '%s', '%s', '%s')" % (permis, nom, prenom, adresse, numero, naiss, ID))
    print("Le conducteur a bien été ajouté")
    
def ModCond(conn, ID):
    cond = input("\nQuel est le numéro de permis du conducteur à modifier ? ")
    while not cond:
        cond = input("\nQuel est le numéro de permis du conducteur à modifier ? ")
    ligne = connexion.requete("SELECT * FROM projet.conducteur WHERE numeropermis = '%s'" % (cond)) #Récupère le conducteur pour être sur qu'il existe
    if ligne:
        print("N° Permis  Nom   Prénom  Adresse  N° Télephone  Date de Naissance")
        print("-----------------------------------------------------------------")
        print(ligne[0][0], "|", ligne[0][1], "|", ligne[0][2], "|", ligne[0][3], "|", ligne[0][4], "|", ligne[0][5])
        print("Que vouslez vous modifier ? (2, 3, 4, 5, 6) ")  #Demande quelle variable afficher est a modifier
        modif = connexion.saisie_nb(2,6)
        if modif == 2:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.conducteur SET nom='%s' WHERE numeropermis = '%s'" % (val, cond))
        elif modif == 3:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.conducteur SET prenom='%s' WHERE numeropermis = '%s'" % (val, cond))
        elif modif == 4:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.conducteur SET adresse='%s' WHERE numeropermis = '%s'" % (val, cond))
        elif modif == 5:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.conducteur SET numerotel='%s' WHERE numeropermis = '%s'" % (val, cond))
        elif modif == 6:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.conducteur SET datenaissance='%s' WHERE numeropermis = '%s'" % (val, cond))
        ligne = connexion.requete("SELECT * FROM projet.conducteur WHERE numeropermis = '%s'" % (cond))
        print(ligne[0][0], "|", ligne[0][1], "|", ligne[0][2], "|", ligne[0][3], "|", ligne[0][4], "|", ligne[0][5])  #On affiche la lligne modifié pour contrôler
    else:
        print("Ce numéro de permis n'existe pas")
        
def SupCond(conn, ID):
    cond = input("\nQuel est le numéro de permis du conducteur à supprimer ? ")
    while not cond:
        cond = input("\nQuel est le numéro de permis du conducteur à supprimer ? ")
    ligne = connexion.requete("SELECT * FROM projet.conducteur WHERE numeropermis = '%s'" % (cond))
    if ligne:
        print("N° Permis  Nom   Prénom  Adresse  N° Télephone  Date de Naissance")
        print("-----------------------------------------------------------------")
        print(ligne[0][0], "|", ligne[0][1], "|", ligne[0][2], "|", ligne[0][3], "|", ligne[0][4], "|", ligne[0][5])
        sur = input("Etes vous sur de vouloir le supprimer ? (oui / non) ")  #On verifie que l'on veut vraiment suprimer ce conducteur
        while not sur:
            sur = input("Etes vous sur de vouloir le supprimer ? (oui / non) ")
        if sur == 'oui':
            connexion.requete("DELETE FROM projet.conducteur WHERE numeropermis = '%s'" % (cond))
            print("Supression terminée !")
        else: print("D'accord, suppression annulée")
        
def AffLoc(conn, ID):
    #On récupère les infos utiles des locations lié au client
    ligne = connexion.requete("SELECT contratlocation.idcontrat, datereservation, heuredebut, heurefin, datedebutlocation, datefinlocation, kilometrage, vehicule FROM projet.contratlocation, projet.conducteur, projet.contratprofessionnel WHERE contratprofessionnel.idcontrat = contratlocation.idcontrat and conducteur.numeropermis = contratprofessionnel.conducteur and conducteur.clientprofessionnel = %s" % (ID))
    if ligne:
        print("\nListe des locations : ")
        print("\nID  DateRes  HeureDébut  HeureFin  DateDébut  DateFin  KM  Vehicule")
        print("-------------------------------------------------------------------")
        for i in range(len(ligne)):
                print(ligne[i][0], "|", ligne[i][1], "|", ligne[i][2], "|", ligne[i][3], "|", ligne[i][4], "|", ligne[i][5], "|", ligne[i][6], "|", ligne[i][7])
    else: 
        print("\nIl n'y a pas de locations")

def AjLoc(conn, ID):
 #On demande toutes les infos pour créer une location (il faut ajouter un agent commercial 0)
    dateRes = datetime.date.today()
    heureD = input("\nVeuillez entrer l'heure de départ (HH:MM:SS) : ")
    while not heureD:
        heureD = input("\nVeuillez entrer l'heure de départ (HH:MM:SS) : ")
    heureF = input("Veuillez entrer l'heure de fin (HH:MM:SS) : ")
    while not heureF:
        heureF = input("Veuillez entrer l'heure de fin (HH:MM:SS) : ")
    dateD = input("Veuillez entrer la date du début de la réservation (DD-MM-YYYY) : ")
    while not dateD:
        dateD = input("Veuillez entrer la date du début de la réservation (DD-MM-YYYY) : ")
    dateF = input("Veuillez entrer la date du fin de la réservation (DD-MM-YYYY) : ")
    while not dateF:
        dateF = input("Veuillez entrer la date du fin de la réservation (DD-MM-YYYY) : ")
    km = input("Veuillez entrer le nombre de kilomètre prévu : ")
    while not km:
        km = input("Veuillez entrer le nombre de kilomètre prévu : ")
    vehicule = input("Veuillez entrer la plaque d'immatriculation du véhicule choisi : ")
    while not vehicule:
        vehicule = input("Veuillez entrer la plaque d'immatriculation du véhicule choisi : ")
    ligne = connexion.requete("SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule LEFT JOIN projet.ContratLocation ON  projet.Vehicule.immat = projet.ContratLocation.vehicule WHERE (projet.ContratLocation.vehicule IS NULL OR projet.ContratLocation.entretien IS NOT NULL) AND projet.ContratLocation.vehicule = '%s'" % (vehicule))
    while ligne == []:
        print("Le véhicule ne peut pas être loué")
        vehicule = input("Veuillez entrer la plaque d'immatriculation du véhicule choisi : ")
        while not vehicule:
            vehicule = input("Veuillez entrer la plaque d'immatriculation du véhicule choisi : ")
        ligne = connexion.requete("SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule LEFT JOIN projet.ContratLocation ON  projet.Vehicule.immat = projet.ContratLocation.vehicule WHERE (projet.ContratLocation.vehicule IS NULL OR projet.ContratLocation.entretien IS NOT NULL) AND projet.ContratLocation.vehicule = '%s'" % (vehicule))
    #on demande si une facturation existe déjà pour la location, sinon il faut en créer une
    idfact = input("La location est-elle déjà liée à une facturation ? (si oui donner le numéro de la facturation, si non appuyer sur entrée) ")
    if idfact != '':
        idfact = connexion.requete("SELECT projet.facturation.idfact FROM projet.facturation where idfact = '%s'" % (idfact))
    elif idfact == '':    
        connexion.requete("INSERT INTO projet.facturation VALUES ('DEFAULT')") #On créer une facturation sans aucune autre info
        idfact = connexion.requete("SELECT MAX(projet.facturation.idfact) FROM projet.facturation") #On récupère l'id de la facturation créé
    #on créer la location
    connexion.requete("INSERT INTO projet.contratlocation (datereservation, heuredebut, heurefin, datedebutlocation, datefinlocation, kilometrage, vehicule, agent, facturation) values ('%s', '%s', '%s', '%s', '%s', '%s', '%s', 'DEFAULT', '%s')" % (dateRes, heureD, heureF, dateD, dateF, km, vehicule, idfact[0][0]))
    #on récupère l'id du contrat créer
    idcontrat = connexion.requete("SELECT MAX(projet.contratlocation.idcontrat) FROM projet.contratlocation")
    #on créer l'association entre la location et le conducteur
    connexion.requete("INSERT INTO projet.contratprofessionnel values ('%s', '%s')" % (idcontrat[0][0], ID))
    print("La location a bien été ajouté")
    
def ModLoc(conn, ID):
    cond = input("\nQuel est le numéro de la location à modifier ? ")
    while not cond:
        cond = input("Quel est le numéro de la location à modifier ? ")
    #On récupère la liste des infos utiles de la location pour vérifier que c'est bien celle voulue
    ligne = connexion.requete("SELECT contratlocation.idcontrat, datereservation, heuredebut, heurefin, datedebutlocation, datefinlocation, kilometrage, vehicule FROM projet.contratlocation, projet.contratprofessionnel WHERE contratlocation.idcontrat = '%s' and contratprofessionnel.conducteur = '%s'" % (cond, ID))
    if ligne:
        print("ID  DateRes  HeureDébut  HeureFin  DateDébut  DateFin  KM  Vehicule")
        print("-------------------------------------------------------------------")
        print(ligne[0][0], "|", ligne[0][1], "|", ligne[0][2], "|", ligne[0][3], "|", ligne[0][4], "|", ligne[0][5], "|", ligne[0][6], "|", ligne[0][7])
        print("Que vouslez vous modifier ? (3, 4, 5, 6, 7, 8) ")   #Choix entre les différents attributs modifiable (commence à 2 car l'ID n'est pas modifiable)
        modif = connexion.saisie_nb(3,8)
        if modif == 3:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.contratlocation SET heuredebut='%s' WHERE idcontrat = '%s'" % (val, cond))
        elif modif == 4:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.contratlocation SET heurefin='%s' WHERE idcontrat = '%s'" % (val, cond))
        elif modif == 5:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.contratlocationr SET datedebutlocation='%s' WHERE idcontrat = '%s'" % (val, cond))
        elif modif == 6:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.contratlocation SET datefinlocation='%s' WHERE idcontrat = '%s'" % (val, cond))
        elif modif == 7:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.contratlocation SET kilometrage='%s' WHERE idcontrat = '%s'" % (val, cond))
        elif modif == 8:
            val = input("Quelle est la nouvelle valeur ? ")
            while not val:
                val = input("Quelle est la nouvelle valeur ? ")
            connexion.requete("UPDATE projet.contratlocation SET vehicule='%s' WHERE idcontrat = '%s'" % (val, cond))
        #On affiche la ligne modifié pour vérifier qu'il n'y a pas d'erreur
        ligne = connexion.requete("SELECT contratlocation.idcontrat, datereservation, heuredebut, heurefin, datedebutlocation, datefinlocation, kilometrage, vehicule FROM projet.contratlocation, projet.contratprofessionnel WHERE contratlocation.idcontrat = '%s' and contratprofessionnel.conducteur = '%s'" % (cond, ID))
        print(ligne[0][0], "|", ligne[0][1], "|", ligne[0][2], "|", ligne[0][3], "|", ligne[0][4], "|", ligne[0][5], "|", ligne[0][6], "|", ligne[0][7])
    else:
        print("Ce numéro de location n'existe pas")
    

def menu_client_pro():
    connexion.screen_clear()
    conn = connexion.connexion()
    print("\n\t--- Menu Client Professionnel ---")
    #test pour créer ou non un nouveau client professionnel
    test = input("Etes vous un nouveau client ? (oui / non) ")
    while not test:
        test = input("Etes vous un nouveau client ? (oui / non) ")
    
    if test == "oui":
        #On récupère les infos pour créer un nouveau client professionnel
        nom = input("Quel est le nom de votre entreprise ? ")
        while not nom:
            nom = input("Quel est le nom de votre entreprise ? ")
        infos = input("Donnez des informations sur votre entreprise ")
        while not infos:
            infos = input("Donnez des informations sur votre entreprise ")
        connexion.requete("INSERT INTO projet.clientprofessionnel (idclient, nom, infosentreprise) values (nextval('seq_idClientProfessionnel'), '%s', '%s')" % (nom, infos))
        #on récupère l'id du client créer pour pouvoir l'afficher au client
        ID = connexion.requete("SELECT MAX(projet.clientprofessionnel.idclient) FROM projet.clientprofessionnel")
        print("")
        print("Ton ID est : ", ID[0][0])
        
    elif test == "non":
        #On récupère l'id du client pour vérifier qu'il existe
        ID = input("Quel est votre identifiant ? ")
        ligne = connexion.requete("SELECT projet.clientprofessionnel.idclient, nom FROM projet.clientprofessionnel WHERE '%s' = projet.clientprofessionnel.idclient" % (ID))
        if ligne:
            n = '1'
            print("\nBonjour %s" % ligne[0][1])
            #Menu pour pouvoir executer les différentes actions possibles
            while n != 8:
                print("\n1. Afficher la liste des conducteurs")
                print("2. Ajouter un conducteur")
                print("3. Modifier un conducteur")
                print("4. Supprimer un conducteur")
                print("5. Afficher la liste des locations")
                print("6. Ajouter une location")
                print("7. Modifier une location")
                print("8. Sortir")
                print("Que souhaitez vous faire ? ")
                n = connexion.saisie_nb(1,8)
                if n == 1:
                    AffCond(conn, ID)
                if n == 2:
                    AjCond(conn, ID)
                if n == 3:
                    ModCond(conn, ID)
                if n == 4:
                    SupCond(conn, ID)
                if n == 5:
                    AffLoc(conn, ID)
                if n == 6:
                    cond = input("Pour quel conducteur souhaitez vous réserver ? ")
                    AjLoc(conn, cond)
                if n == 7:
                    cond = input("Pour quel conducteur souhaitez vous modifier la location ? ")
                    ModLoc(conn, cond)
                
        else:
            print("Ce client n'existe pas")
    
    else: print("Revenez en arrière")

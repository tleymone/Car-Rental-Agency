import connexion

def AjouterVoiture(agence):

    connexion.screen_clear()

    print("-Ajouter Voiture-\n")
    print("Pour ajouter une voiture inserez les données suivantes:")
    immat = input("Immatriculation: ")
    marque = input("Marque: ")
    couleur = input("Couleur: ")
    tarif = input("Tarif: ")
    km = input("Kilomètres: ")
    nomModele = input("Nom du modèle: ")
    typeCarburant = input("Type de carburant: ")

    connexion.requete("INSERT INTO projet.Vehicule VALUES('%s', '%s', '%s', %s, %s, '%s', '%s', '%s')"%(immat, marque, couleur, tarif, km, nomModele, typeCarburant, agence))

def SupprimerVoiture(agence):

    connexion.screen_clear()
    print("-Supprimer Voiture-\n")
    print("Pour supprimer une voiture, inserez la donnée suivante:")
    immat = input("Immatriculation: ")
    if len(connexion.requete("SELECT * FROM projet.vehicule WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(immat, agence))) == 0:
        print("La vehicule n'existe pas")
    else:
        connexion.requete("DELETE FROM projet.AssocOptions WHERE projet.AssocOptions.vehicule='%s'"%immat)
        connexion.requete("DELETE FROM projet.ContratLocation WHERE projet.ContratLocation.vehicule='%s'"%immat)
        connexion.requete("DELETE FROM projet.vehicule WHERE projet.vehicule.immat='%s'"%immat)

def ModifierAttributsVehicule(immat, agence):

    print("Insérez la nouvelle valeur du champ, sinon -1")

    couleur = input("Couleur: ")
    tarif = input("Tarif: ")
    km = input("Kilométres: ")

    req = ""

    if couleur != "-1":
        req = "UPDATE projet.vehicule SET couleur='%s' WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(couleur, immat, agence)

    if tarif != "-1":
        req = "UPDATE projet.vehicule SET tarif='%s' WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(tarif, immat, agence)

    if km != "-1":
        req = "UPDATE projet.vehicule SET km='%s' WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(km, immat, agence)

    if (couleur != "-1") and (tarif != "-1"):
        req = "UPDATE projet.vehicule SET couleur='%s', tarif='%s' WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(couleur, tarif, immat, agence)

    if (tarif != "-1") and (km != "-1"):
        req = "UPDATE projet.vehicule SET tarif='%s', km='%s' WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(tarif, km, immat, agence)

    if (couleur != "-1") and (km != "-1"):
        req = "UPDATE projet.vehicule SET couleur='%s', km='%s' WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(couleur, km, immat, agence)

    if (couleur != "-1") and (tarif != "-1") and (km != "-1"):
        req = "UPDATE projet.vehicule SET couleur='%s', km='%s', tarif='%s' WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(couleur, km, tarif, immat, agence)

    connexion.requete(req)

def AjouterOption(immat, agence):
     
    Options1 = connexion.requete("SELECT * FROM projet.options")
    Options2 = []
    Options3 = []
    Options2.append(["Numero", "Option"])
    #Options2.append("Option")
    i = 1
    for a in Options1:
        #print(a)
        Options3.append(a[0])
        a.append(str(i))
        a.reverse()
        Options2.append(a)
        i+=1
    select=""
    connexion.afficher_L_o_L(Options2)
    select=input("Inserez le nombre de l'option à ajouter -> ")

    connexion.requete("INSERT INTO projet.AssocOptions VALUES('%s', '%s')"%(immat, Options3[int(select)]))
    

def ModifierVoiture(agence):    

    selection = ""

    while( selection != "0"):

        connexion.screen_clear()
        print("-Modifier Voiture-")
        immat=input("Inserez l'immatriculation de la voiture à modifier\n(0 pour retourner)\n")

        if len(connexion.requete("SELECT * FROM projet.vehicule WHERE projet.vehicule.immat='%s' AND projet.vehicule.agence='%s'"%(immat, agence))) == 0:
            if immat=="0":
                print("Retourne au menu")
            else:
                print("La vehicule n'existe pas")
            selection = "0"
        else:

            selection=input("""Inserez le type de modification à faire
            
            1) Ajouter Option
            2) Changer Attribut
            
            0) Sortir
            """)
            print("")
            if selection == "1":
                AjouterOption(immat, agence)

            elif selection == "2":

                ModifierAttributsVehicule(immat, agence)

    connexion.screen_clear()

def AfficherVoiture(agence):

    connexion.screen_clear()

    print("-Voitures Disponibles-\n")
    connexion.afficher_L_o_L(connexion.requete("SELECT DISTINCT projet.Vehicule.* FROM projet.Vehicule LEFT JOIN projet.ContratLocation ON  projet.Vehicule.immat = projet.ContratLocation.vehicule WHERE (projet.ContratLocation.vehicule IS NULL OR projet.ContratLocation.entretien IS NOT NULL) AND projet.vehicule.agence='%s'"%agence))

def VoituresAEntretener():

    print("-Voitures à entretener-\n")
    connexion.afficher_L_o_L(connexion.requete("SELECT projet.vehicule.* FROM projet.vehicule INNER JOIN projet.contratlocation ON projet.vehicule.immat = projet.contratlocation.vehicule WHERE projet.contratlocation.entretien IS NULL AND projet.contratlocation.datefinlocation IS NOT NULL"))

#AfficherVoiture("Rent A Car Compiegne")
#connexion.os.system('pause')
#SupprimerVoiture("Rent A Car Compiegne")
#ModifierVoiture("Rent A Car Compiegne")

def EntretienProcessus(agence):#date.fromisoformat('2019-12-04')

    connexion.screen_clear()

    print("-Entretien des voitures-")

    VoituresAEntretener()

    immat=input("\nInserez l'immatriculation de la voiture à entretener(0 pour retourner au menu):")
    if immat=="0":
        print("Retour au menu")
        return
    datefin = (connexion.requete("SELECT projet.ContratLocation.datefinlocation FROM projet.vehicule INNER JOIN projet.ContratLocation ON projet.ContratLocation.vehicule = projet.vehicule.immat WHERE projet.vehicule.immat = '%s'"%immat).pop()).pop()

    #print(datefin)
    datefin = connexion.date.fromisoformat(str(datefin))
    dateEntretien = input("Inserez la date de l'entretien: ")
    dateEntretien = connexion.date.fromisoformat(str(dateEntretien))

    if datefin < dateEntretien:

        print("Entretien effectue par:")
        typeEn=input("""
1) Societe d'entretien
2) Agent Techinque        
""")

        numeroEnt = ""

        if typeEn == "1":
            numeroEnt = input("Inserez le numero: ")
            connexion.requete("INSERT INTO projet.Entretien VALUES(DEFAULT, '%s', '%s', NULL)"%(str(dateEntretien), str(numeroEnt)))
        elif typeEn == "2":
            connexion.requete("INSERT INTO projet.Entretien VALUES(DEFAULT, '%s', NULL, '%s')"%(str(dateEntretien), str(numeroEnt)))

        connexion.requete("UPDATE projet.ContratLocation SET entretien='%s' WHERE vehicule ='%s'"%((int((connexion.requete("SELECT count(*) from projet.entretien").pop()).pop())-1), immat))

def MenuTechnique():

    while True:
        print("""
Agent Technique

    1 - Ajouter voiture
    2 - Supprimer voiture
    3 - Modifier voiture
    4 - Processus d'entretien
    
    0 - Retourner au menu
        """)

        choice = connexion.saisie_nb(0,5)

        if(choice == 0):
            
            break

        elif(choice == 1):
            AjouterVoiture("Rent A Car Compiegne")
        elif(choice == 2):
            SupprimerVoiture("Rent A Car Compiegne")
        elif(choice == 3):
            ModifierVoiture("Rent A Car Compiegne")
        #elif(choice == 4):
        #    AfficherVoiture("Rent A Car Compiegne")
        #elif(choice == 5):
            #VoituresAEntretener()
        elif(choice == 4):
            EntretienProcessus("Rent A Car Compiegne")

#c = connexion.requete("SELECT * from projet.entretien")
#
#for a in c:
#    print(a)
from time import sleep
import connexion
import psycopg2


def menu_agent_technique():
    connexion.screen_clear()

    while True:
        print("\n\t--- Que voulez-vous faire ? ---")
        print("\n\t1.\tCréer un véhicule.")
        print("\n\t2.\tModifier un véhicule.")
        print("\n\t3.\tSupprimer un véhicule.")
        print("\n\t4.\tInterrogations.")

        choice = connexion.saisie_nb(1,4)

        if(choice == 1):
            connexion.screen_clear()
            creer_vehicule()
        elif(choice == 2):
            connexion.screen_clear()
            modifier_vehicule()
        elif(choice == 3):
            connexion.screen_clear()
            supprimer_vehicule()
        elif(choice == 4):
            connexion.screen_clear()
            interrogations()


def creer_vehicule():

    print("--- Veuillez rentrer les informations suivantes ---\n")

    immat = input("Immatriculation: ")
    marque = input("Marque: ")
    couleur = input("Couleur: ")
    tarif = input("Id du tarif: ")
    typeCarburant = input("Type de carburant: ")
    nomAgence = input("Nom de l'agence: ")

    Agence = '{"nom":"%s"}'%nomAgence
    Carburant = '{"typeCarburant":"%s"}'%typeCarburant

    connexion.requete("INSERT INTO nosql.Vehicule VALUES ('%s', '%s', '%s', '%s','%s')"%
    (immat, marque, couleur, tarif, Carburant, Agence))


def modifier_vehicule():
    # Modification de l'attribut typeCarburant pour montrer le fonctionnement
    # d'un UPDATE avec rjson

    immat = input("Immatriculation: ")
    while not immat:
        immat = input("Immatriculation: ")

    vehicule = connexion.requete("SELECT * FROM nosql.Vehicule WHERE nosql.Vehicule.immat='%s'"%(immat))

    if vehicule:
        typeCarburant = input("Nouveau type de carburant : ")
        while not typeCarburant:
            typeCarburant = input("Nouveau type de carburant : ")

        Carburant = '{"typeCarburant":"%s"}'%typeCarburant
        connexion.requete("UPDATE nosql.Vehicule SET typeCarburant = '%s' WHERE immat = '%s'"%(Carburant, vehicule[0][0]))
        sleep(1)
        connexion.screen_clear()
    else:
        print("Erreur dans le numéro d'immatriculation...")
        sleep(2)
    

def supprimer_vehicule():
    connexion.screen_clear()
    
    immat = input("Immatriculation de la voiture à supprimer : ")
    while not immat:
        immat = input("Immatriculation de la voiture à supprimer : ")

    vehicule = connexion.requete("SELECT * FROM nosql.Vehicule WHERE nosql.Vehicule.immat='%s'"%(immat))

    if not vehicule:
        print("Erreur dans le numéro de d'immatriculation...")
        sleep(2)
    else:
        connexion.requete("DELETE FROM nosql.Vehicule WHERE nosql.Vehicule.immat='%s'"%immat)


def interrogations():

    print("\nAfficher tous les véhicules\n")
    connexion.afficher_L_o_L(connexion.requete("SELECT v.immat, v.marque, v.couleur, v.idR2, v.typeCarburant->>'typeCarburant', v.agence->>'nom' FROM nosql.Vehicule v"))

    print("Afficher tous les véhicules qui appartiennent à une agence demandée \n")
    agence = input("Quelle nom d'agence choissisez-vous ? : ")
    while not agence:
        agence = input("Quelle nom d'agence choissisez-vous ? : ")
    connexion.afficher_L_o_L(connexion.requete("SELECT v.immat, v.marque, v.couleur, v.idR2, v.typeCarburant->>'typeCarburant', v.agence->>'nom' FROM nosql.Vehicule v WHERE v.agence->>'nom' ='%s'"%(agence)))
    connexion.screen_clear()
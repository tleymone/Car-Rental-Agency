#!/usr/bin/python3

from time import sleep
import connexion
import psycopg2

def Afficherinvalide():

    print("Affichage des réservations en attente de validation:")#Les réservations qu n'ont pas été encore validées ont O dans le champ agent
    result = connexion.requete("SELECT * FROM nosql.contratlocation WHERE agent= NULL")


    if (result):
        #affichage des réservations nons validées
        while result:
            id = result[0]
            datereservation = result[1]
            heuredebut = result[2]
            heurefin = result[3]
            datedebut = result[4]
            datefin = result[5]
            kilometrage = result[6]
            vehicule= result[7]
            facturation= result[9]
            print ("id: %s     datereservation:%s   heuredebut:%s   heurefin:%s     datedebut:%s    datefin:%s  kilometrage:%s  vehicule:%s    facturation:%s" % (id, datereservation, heuredebut, heurefin, datedebut, datefin, kilometrage, vehicule, facturation))
            print("------------------------------------------------------------------------------------------------------------------------------------------------------")

        return 1
    else:
        print("Toutes les réservations sont validées")
        return 0


def Location() :
    
    #   On suppose au début les données de l'agent stockées dans un Json
    #   Donc, au moment de valider ou supprimer un location il faut envoyer
    #   toutes les données de l'agent dans ce format.

    print("Gestion des contrats location")
    agent = '{"numsecusocial":11824521,"nom":"Martin","prenom":"Gabriel","dateNaissance":"1986-09-20","agence":"Rent A Car Compiègne"}'

    while choix:
        invalide = Afficherinvalide()
        choix = 0
        if (invalide ==1):
            print("Souhaitez vous:")
            print("(1) Valider ")
            print("(2) Supprimer")
            print("(0) Retour")

            choix = input()

            #Valider une location
            if choix == "1":
                id =int(input("Entrer id de location à valider:"))
                #on entre notre code agent pour signifier que la reservation a été validée
                connexion.requete("UPDATE nosql.contratlocation SET agent='%s' WHERE agent=NULL AND idcontrat=%s" %(agent,id))
                print("La validation a été réalisée")

            #Supression
            if choix == "2":
                id =int(input("Entrer id de location à supprimer:"))
                connexion.requete("DELETE FROM projet.contratparticulier  WHERE idContrat= %d"%id)
                connexion.requete("DELETE FROM projet.ContratProfessionnel  WHERE idContrat= %d"%id)
                connexion.requete("DELETE FROM projet.ContratLocation WHERE idContrat= %d"%id)
                print("La validation a été supprimée")




    return 0

Location()
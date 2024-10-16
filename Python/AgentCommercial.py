#!/usr/bin/python3

import psycopg2
import facture
import location
import stats

def menu_agent_commercial():

    HOST = "tuxa.sme.utc"
    USER = "nf18p071"
    PASSWORD = "D7MxPqso"
    DATABASE = "dbnf18p071"

    conn = psycopg2.connect("host=%s dbname=%s user=%s password=%s" % (HOST, DATABASE, USER, PASSWORD))

    choice = '1'
    quitter ='1'
    while choice != "0":
        print("------------------------------")
        print ("Que souhaitez vous faire ?")
        print ("(1) Gérer les locations")
        print ("(2) Editer les facturations")
        print ("(3) Obtenir les statistiques")
        print ("(0) Quitter")
        choice = input()


        if (choice == "1"):
            while quitter != "0":
                print("(1) Gérer les locations")
                print("(2) Afficher les locations")
                print("(0) Retour")
                quitter = input()

                if quitter == "1":
                    location.Location(conn)

                if quitter == "2":
                    location.AfficherTout(conn)


        if (choice == "2"):
            facture.Facture(conn)




        if (choice == "3"):
            while quitter != "0":
                print("(1) Par client")
                print("(2) Par voiture")
                print("(3) Par catégorie de voiture")
                print("(0) Retour")
                quitter = input()

                if quitter == "1":
                    stats.StatClient(conn)
                if quitter == "2":
                    stats.StatVehicule(conn)
                if quitter =='3':
                    stats.StatCategorie(conn)









    conn.close()

#!/usr/bin/python3

import psycopg2

def Afficherinvalide(conn):

    cur= conn.cursor()
    print("Affichage des réservations en attente de validation:")#Les réservations qu n'ont pas été encore validées ont O dans le champ agent
    sql="SELECT * FROM projet.contratlocation WHERE agent= NULL"
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()

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
            entretien= result[10]
            print ("id: %s     datereservation:%s   heuredebut:%s   heurefin:%s     datedebut:%s    datefin:%s  kilometrage:%s  vehicule:%s    facturation:%s     entretien:%s" % (id, datereservation, heuredebut, heurefin, datedebut, datefin, kilometrage, vehicule, facturation, entretien))
            print("------------------------------------------------------------------------------------------------------------------------------------------------------")
            result= cur.fetchone()

        return 1
    else:
        print("Toutes les réservations sont validées")
        return 0


def Location(conn) :

    cur = conn.cursor()
    choix = 1

    #entrer nom agent
    num = input("entrez votre numéro de sécurité sociale:")

    sql = "SELECT * FROM projet.agentcommercial WHERE numsecusociale='%s'"%num

    cur.execute (sql)
    conn.commit()

    raw = cur.fetchone()
    if (raw):

        while choix:
            invalide = Afficherinvalide(conn)
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
                    sql="UPDATE projet.contratlocation SET agent='%s' WHERE agent=NULL AND idcontrat=%s" %(num,id)
                    cur.execute (sql)
                    conn.commit()
                    print("La validation a été réalisée")

                #Supression
                if choix == "2":
                    id =int(input("Entrer id de location à supprimer:"))
                    sql = "DELETE FROM projet.contratparticulier  WHERE idContrat= %d"%id
                    cur.execute (sql)
                    conn.commit()
                    sql = "DELETE FROM projet.ContratProfessionnel  WHERE idContrat= %d"%id
                    cur.execute (sql)
                    conn.commit()
                    sql = "DELETE FROM projet.ContratLocation WHERE idContrat= %d"%id
                    cur.execute (sql)
                    conn.commit()
                    print("La validation a été supprimée")


    else:
        print("Code invalide")



    return 0


def AfficherTout(conn) : #ajouter le client associé
    cur = conn.cursor()
    sql = "SELECT * FROM projet.contratlocation contrat JOIN projet.contratparticulier particulier ON contrat.idcontrat =  particulier.idcontrat JOIN projet.ClientParticulier client ON particulier.clientparticulier = client.idclient ORDER BY contrat.datereservation"
    cur.execute (sql)
    conn.commit()

    raw = cur.fetchone()
    while raw:
        datereservation = raw[1]
        heuredebut = raw[2]
        heurefin = raw[3]
        datedebut = raw[4]
        datefin = raw[5]
        kilometrage = raw[6]
        vehicule= raw[7]
        nomconducteur = raw[15]
        prenomconducteur= raw[16]

        print ("datereservation:%s   heuredebut:%s   heurefin:%s     datedebut:%s    datefin:%s  kilometrage:%s  vehicule:%s     nom conducteur:%s     prenom conducteur:%s" % (datereservation, heuredebut, heurefin, datedebut, datefin, kilometrage, vehicule, nomconducteur, prenomconducteur))
        print("------------------------------------------------------------------------------------------------------------------------------------------------------")
        raw = cur.fetchone()

    return 0

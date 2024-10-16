#!/usr/bin/python3

from time import sleep
import connexion
import psycopg2


def Facture() :
    
    #   On suppose au début les données de l'agent stockées dans un Json
    #   Donc, au moment de valider ou supprimer un location il faut envoyer
    #   toutes les données de l'agent dans ce format.

    montant = 0
    
    print("Gestion des contrats location")
    agent = '{"numsecusocial":11824521,"nom":"Martin","prenom":"Gabriel","dateNaissance":"1986-09-20","agence":"Rent A Car Compiègne"}'

    print("(1) Client Client Professionel")
    print("(2) Client Client Particulier")
    choix= input()
    client= input("Entrez l'id du client qui souhaite payer la facture:")

    resultat = ""

    if choix == '1':
        resultat = connexion.requete("SELECT * FROM projet.ContratProfessionnel JOIN projet.ContratLocation ON ContratProfessionnel.idcontrat = ContratLocation.idcontrat JOIN projet.facturation ON contratlocation.facturation = facturation.idfact WHERE ContratProfessionnel.conducteur='%s' AND facturation.agentcommercial = NULL"%(client))

    if choix == '2':
        resultat = connexion.requete("SELECT * FROM projet.ContratParticulier JOIN projet.ContratLocation ON ContratParticulier.idcontrat = ContratLocation.idcontrat JOIN projet.facturation ON contratlocation.facturation = facturation.idfact WHERE ContratParticulier.clientparticulier='%s' AND facturation.agentcommercial = NULL"%(client))

    if (resultat):
        print("Liste de toutes les factures à payer:")
        while resultat:
            #montant à payer
            voiture = resultat[9]
            tarif = Tarif(conn, voiture)

            datedeb = resultat[6]
            datefin = resultat[7]

            intervalle = datefin - datedeb
            montant = tarif * (intervalle.days + 1)

            kilometrage = int(resultat[8])
            if kilometrage > 100:
                prixseuil = int(input("A combien est facturé le kilometre au dessus du seuil ?:"))
                montant = montant + (prixseuil*(kilometrage - 100))

            idfacture = resultat[13]
            print ("La facture de id: ",idfacture," montant: ",montant," euros")

            choix= input("Voulez-vous régler maintenant ? (O/N):")
            print()
            if(choix=='O'):
                Payer(idfacture, agent, montant)
                print("Facture payée")
                print()




    else:
        print("Toutes les factures de ce client ont déjà été payées")

    return 0


def Tarif(voiture):
    
    resultvoiture = connexion.requete("SELECT tarif from nosql.vehicule WHERE immat='%s'"%voiture)
    tarif = resultvoiture[0]
    return tarif


def Payer(idfacturation, idagent, montant):

    sql = connexion.requete("UPDATE nosql.Facturation SET dateFacturation= CURRENT_DATE WHERE idfact='%s'"%idfacturation)

    print("Moyen de règlement:")
    print("(1) CB")
    print("(2) chèque")
    print("(3) espèces")
    print("(4) virement")
    choix = input()

    if choix == '1':
        reglement='CB'
    if choix == '2':
        reglement='cheque'
    if choix == '3':
        reglement='especes'
    if choix == '4':
        reglement='virement'

    sql = connexion.requete("UPDATE nosql.Facturation SET moyenreglement= '%s' WHERE idfact='%s'"%(reglement, idfacturation))

    sql = connexion.requete("UPDATE nosql.Facturation SET montant= %d WHERE idfact='%s'"%(montant, idfacturation))

    sql = connexion.requete("UPDATE nosql.Facturation SET agentcommercial= '%s' WHERE idfact='%s'"%(idagent, idfacturation))

    return 0

Facture()
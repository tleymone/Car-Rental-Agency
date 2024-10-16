#!/usr/bin/python3

import psycopg2

def Facture(conn) :

    cur = conn.cursor()
    montant = 0

    #entrer nom agent
    num = input("entrez votre numéro de sécurité sociale:")

    sql = "SELECT * FROM projet.agentcommercial WHERE numsecusociale='%s'"%num

    cur.execute (sql)
    conn.commit()

    raw = cur.fetchone()
    if (raw):

        print("(1) Client Client Professionel")
        print("(2) Client Client Particulier")
        choix= input()
        client= input("Entrez l'id du client qui souhaite payer la facture:")

        if choix == '1':
            sql = "SELECT * FROM projet.ContratProfessionnel JOIN projet.ContratLocation ON ContratProfessionnel.idcontrat = ContratLocation.idcontrat JOIN projet.facturation ON contratlocation.facturation = facturation.idfact WHERE ContratProfessionnel.conducteur='%s' AND facturation.agentcommercial = NULL"%(client)

        if choix == '2':
            sql = "SELECT * FROM projet.ContratParticulier JOIN projet.ContratLocation ON ContratParticulier.idcontrat = ContratLocation.idcontrat JOIN projet.facturation ON contratlocation.facturation = facturation.idfact WHERE ContratParticulier.clientparticulier='%s' AND facturation.agentcommercial = NULL"%(client)


        cur.execute (sql)
        conn.commit()

        result = cur.fetchone()
        if (result):
            print("Liste de toutes les factures à payer:")
            while result:
                #montant à payer
                voiture = result[9]
                tarif = Tarif(conn, voiture)

                datedeb = result[6]
                datefin = result[7]

                intervalle = datefin - datedeb
                montant = tarif * (intervalle.days + 1)

                kilometrage = int(result[8])
                if kilometrage > 100:
                    prixseuil = int(input("A combien est facturé le kilometre au dessus du seuil ?:"))
                    montant = montant + (prixseuil*(kilometrage - 100))

                idfacture = result[13]
                print ("La facture de id: ",idfacture," montant: ",montant," euros")

                choix= input("Voulez-vous régler maintenant ? (O/N):")
                print()
                if(choix=='O'):
                    Payer(conn, idfacture, num, montant)
                    print("Facture payée")
                    print()

                result = cur.fetchone()





        else:
            print("Toutes les factures de ce client ont déjà été payées")



    else:
        print("Code invalide")



    return 0


def Tarif(conn, voiture):
    cur=conn.cursor()
    sql= "SELECT tarif from projet.vehicule WHERE immat='%s'"%voiture
    cur.execute (sql)
    conn.commit()
    resultvoiture = cur.fetchone()
    tarif = resultvoiture[0]
    return tarif


def Payer(conn, idfacturation, idagent, montant):
    cur=conn.cursor()
    sql= "UPDATE projet.Facturation SET dateFacturation= CURRENT_DATE WHERE idfact='%s'"%idfacturation
    cur.execute (sql)
    conn.commit()

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

    sql= "UPDATE projet.Facturation SET moyenreglement= '%s' WHERE idfact='%s'"%(reglement, idfacturation)
    cur.execute (sql)
    conn.commit()

    sql= "UPDATE projet.Facturation SET montant= %d WHERE idfact='%s'"%(montant, idfacturation)
    cur.execute (sql)
    conn.commit()

    sql= "UPDATE projet.Facturation SET agentcommercial= '%s' WHERE idfact='%s'"%(idagent, idfacturation)
    cur.execute (sql)
    conn.commit()
    return 0

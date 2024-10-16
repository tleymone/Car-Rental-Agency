#!/usr/bin/python3

import psycopg2

def StatClient(conn):
    cur=conn.cursor()
    totalnbpro = 0
    totalsommepro = 0
    totalnbpart = 0
    totalsommepart=0
    totalnbclient=0
    totalsommeclient=0

    #clients professionel
    print("Clients professionnels")
    sql = "SELECT * FROM projet.clientprofessionnel"
    cur.execute (sql)
    conn.commit()

    result = cur.fetchone()

    while result:
        id = result[0]
        nom = result[2]

        nb = nbContratpro(conn, id)
        totalnbpro = totalnbpro + nb

        sommemontant = MontantPro(conn, id)
        totalsommepro = totalsommepro + sommemontant

        if nb:
            moyenne = sommemontant / nb
        else:
            moyenne =0

        print("Client: ",nom,"Nombre de contrat: ",nb,"Total des facturations: ",sommemontant,"Moyenne facturation d'un contrat: ",moyenne)
        print()

        result = cur.fetchone()
    totalsommeclient = totalsommeclient + totalsommepro
    totalnbclient = totalnbclient + totalnbpro

    if totalnbpro:
        moyennepro = totalsommepro / totalnbpro
    else:
        moyennepro = 0

    print("TOTAL CLIENTS PROFESSIONNELS")
    print("Nombre de contrat: ",totalnbpro,"Total des facturations: ",totalsommepro,"Moyenne facturation d'un contrat: ",moyennepro)
    print()
    print()

    #clients particuliers
    print("Clients particuliers")
    sql = "SELECT * FROM projet.clientParticulier"
    cur.execute (sql)
    conn.commit()

    result = cur.fetchone()

    while result:
        id = result[0]
        nom = result[2]

        nb = nbContratparticulier(conn, id)
        totalnbpart = totalnbpart + nb

        sommemontant = Montantparticulier(conn, id)
        totalsommepart = totalsommepart + sommemontant

        if nb:
            moyenne = sommemontant / nb
        else:
            moyenne =0

        print("Client: ",nom,"Nombre de contrat: ",nb,"Total des facturations: ",sommemontant,"Moyenne facturation d'un contrat: ",moyenne)
        print()

        result = cur.fetchone()

    totalsommeclient = totalsommeclient + totalsommepart
    totalnbclient = totalnbclient + totalnbpart
    if totalnbpart:
        moyennepart= totalsommepro / totalnbpart
    else:
        moyennepart = 0

    print("TOTAL CLIENTS PARTICULIERS")
    print("Nombre de contrat: ",totalnbpart,"Total des facturations: ",totalsommepart,"Moyenne facturation d'un contrat: ",moyennepart)
    print()
    print()

    #Total Client
    if totalnbclient:
        moyenneclient= totalsommeclient / totalnbclient
    else:
        moyenneclient = 0

    print("TOTAL CLIENT")
    print("Nombre de contrat: ",totalnbclient,"Total des facturations: ",totalsommeclient,"Moyenne facturation d'un contrat: ",moyenneclient)
    print()
    print()







def nbContratpro(conn, id):
        cur=conn.cursor()
        sql = "SELECT COUNT(*) FROM projet.ClientProfessionnel JOIN projet.Conducteur ON clientProfessionnel.idclient = conducteur.clientprofessionnel JOIN projet.ContratProfessionnel ON conducteur.numeroPermis = ContratProfessionnel.conducteur JOIN projet.ContratLocation ON ContratProfessionnel.idcontrat = ContratLocation.idcontrat JOIN projet.facturation ON contratlocation.facturation = facturation.idfact WHERE ClientProfessionnel.idclient='%s' AND facturation.agentcommercial <> NULL"%(id)
        cur.execute (sql)
        conn.commit()
        result = cur.fetchone()
        if (result):
            nbcontratpro = result[0]
        else:
            nbcontratpro = 0
        return nbcontratpro

def MontantPro(conn, id):
    cur=conn.cursor()
    montant = 0
    sql = "SELECT montant FROM projet.facturation JOIN projet.contratlocation ON facturation.idfact = contratlocation.facturation JOIN projet.ContratProfessionnel ON ContratProfessionnel.idcontrat = ContratLocation.idcontrat JOIN projet.conducteur ON conducteur.numeroPermis = ContratProfessionnel.conducteur JOIN projet.clientProfessionnel ON clientProfessionnel.idclient = conducteur.clientprofessionnel WHERE ClientProfessionnel.idclient='%s' AND facturation.agentcommercial <> NULL GROUP BY Facturation.idfact" %(id)
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()
    while result:
        if(result[0]):
            montant = montant +result[0]
        result = cur.fetchone()


    return montant



def nbContratparticulier(conn, id):
    cur= conn.cursor()
    sql = "SELECT COUNT (*) FROM projet.facturation JOIN projet.contratlocation ON facturation.idfact = contratlocation.facturation JOIN projet.ContratParticulier ON ContratParticulier.idcontrat = ContratLocation.idcontrat JOIN projet.clientparticulier ON ContratParticulier.clientparticulier = ClientParticulier.idclient WHERE ClientParticulier.idclient = '%s' AND Facturation.agentcommercial <> NULL"%id
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()
    if (result):
        nbcontratpart = result[0]
    else:
        nbcontratpart= 0
    return nbcontratpart

def Montantparticulier(conn, id):
    cur= conn.cursor()
    montant = 0
    sql = "SELECT montant FROM projet.facturation JOIN projet.contratlocation ON facturation.idfact = contratlocation.facturation JOIN projet.ContratParticulier ON ContratParticulier.idcontrat = ContratLocation.idcontrat JOIN projet.clientparticulier ON ContratParticulier.clientparticulier = ClientParticulier.idclient WHERE ClientParticulier.idclient = '%s' AND Facturation.agentcommercial <> NULL GROUP BY facturation.idfact"%id
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()
    while result:
        if(result[0]):
            montant = montant +result[0]
        result = cur.fetchone()


    return montant





def StatVehicule(conn):
    cur=conn.cursor()
    totalnb = 0
    totalsomme = 0

    print("Véhicule")
    sql = "SELECT immat FROM projet.vehicule"
    cur.execute (sql)
    conn.commit()

    result = cur.fetchone()

    while result:
        immat = result[0]

        nb = nbContratVehicule(conn, immat)
        totalnb = totalnb + nb

        sommemontant = MontantVehicule(conn, immat)
        totalsomme = totalsomme + sommemontant

        if nb:
            moyenne = sommemontant / nb
        else:
            moyenne =0

        print("Véhicule: ",immat,"Nombre de contrat: ",nb,"Total des facturations: ",sommemontant,"Moyenne facturation d'un contrat: ",moyenne)
        print()

        result = cur.fetchone()


    if totalnb:
        totalmoyenne = totalsomme / totalnb
    else:
        totalmoyenne = 0

    print("TOTAL VEHICULES")
    print("Nombre de contrat: ",totalnb,"Total des facturations: ",totalsomme,"Moyenne facturation d'un contrat: ",totalmoyenne)
    print()
    print()

def nbContratVehicule(conn, immat):
    cur= conn.cursor()
    sql = "SELECT COUNT (*) FROM projet.facturation JOIN projet.contratlocation ON facturation.idfact = contratlocation.facturation WHERE contratlocation.vehicule = '%s' AND facturation.agentcommercial <> NULL"%immat
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()
    if (result):
        nbcontratvehicule = result[0]
    else:
        nbcontratvehicule= 0
    return nbcontratvehicule

def MontantVehicule(conn, immat):
    cur= conn.cursor()
    montant = 0
    sql = "SELECT montant FROM projet.facturation JOIN projet.contratlocation ON facturation.idfact = contratlocation.facturation WHERE contratlocation.vehicule = '%s' AND facturation.agentcommercial <> NULL GROUP BY facturation.idFact"%immat
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()
    while result:
        if(result[0]):
            montant = montant +result[0]
        result = cur.fetchone()
    return montant


def StatCategorie(conn):
    cur=conn.cursor()
    totalnb = 0
    totalsomme = 0

    sql = "SELECT * FROM projet.CategorieVehicule"
    cur.execute (sql)
    conn.commit()

    result = cur.fetchone()

    while result:
        categorie = result[0]

        nb = nbContratCategorie(conn, categorie)
        totalnb = totalnb + nb

        sommemontant = MontantCategorie(conn, categorie)
        totalsomme = totalsomme + sommemontant

        if nb:
            moyenne = sommemontant / nb
        else:
            moyenne =0

        print("Catégorie: ",categorie,"Nombre de contrat: ",nb,"Total des facturations: ",sommemontant,"Moyenne facturation d'un contrat: ",moyenne)
        print()

        result = cur.fetchone()


    if totalnb:
        totalmoyenne = totalsomme / totalnb
    else:
        totalmoyenne = 0

    print("TOTAL CATEGORIES")
    print("Nombre de contrat: ",totalnb,"Total des facturations: ",totalsomme,"Moyenne facturation d'un contrat: ",totalmoyenne)
    print()
    print()


def nbContratCategorie(conn, categorie):
    cur= conn.cursor()
    sql = "SELECT COUNT (*) FROM projet.facturation JOIN projet.contratlocation ON facturation.idfact = contratlocation.facturation JOIN projet.Vehicule ON ContratLocation.vehicule = Vehicule.immat JOIN projet.Modele ON Vehicule.nommodele = Modele.nommodele WHERE modele.categorie= '%s' AND facturation.agentcommercial <> NULL"%categorie
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()
    if (result):
        nbcontratcategorie = result[0]
    else:
        nbcontratcategorie= 0
    return nbcontratcategorie

def MontantCategorie(conn, categorie):
    cur= conn.cursor()
    montant = 0
    sql = "SELECT montant FROM projet.facturation JOIN projet.contratlocation ON facturation.idfact = contratlocation.facturation JOIN projet.Vehicule ON ContratLocation.vehicule = Vehicule.immat JOIN projet.Modele ON Vehicule.nommodele = Modele.nommodele WHERE modele.categorie= '%s' AND facturation.agentcommercial <> NULL GROUP BY facturation.idFact"%categorie
    cur.execute (sql)
    conn.commit()
    result = cur.fetchone()
    while result:
        if(result[0]):
            montant = montant +result[0]
        result = cur.fetchone()
    return montant

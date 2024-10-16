#!/usr/bin/python3

from time import sleep
import connexion
import psycopg2


def menu_agent_technique():
    connexion.screen_clear()

    while True:
        print("\n\t--- Que voulez-vous faire ? ---")
        print("\n\t0.\tRevenir au menu principal")
        print("\n\t1.\tEntrer nouveau agent")
        print("\n\t2.\tModifier des informations")
        print("\n\t3.\tSe désinscrire")
        print("\n\t4.\tQuelques interrogations")

        choice = connexion.saisie_nb(0,4)

        if(choice == 0):
            connexion.screen_clear()
            break
        elif(choice == 1):
            connexion.screen_clear()
            inscrire_agent_technique()
        elif(choice == 2):
            connexion.screen_clear()
            modifier_agent()
        elif(choice == 3):
            connexion.screen_clear()
            supprimer_agent()
        elif(choice == 4):
            connexion.screen_clear()
            interrogations()


def inscrire_agent_technique():
    print("--- Veuillez rentrer les informations suivantes ---\n")

    # il faudrait vérifier le format des entrées
    # hypothèse : l'utilisateur rentre des données correctes

    # VERIFIER :


    numsecu = input("Numéro de sécurité sociale : ")
    while not numsecu:
        numsecu = input("Numéro de sécurité sociale : ")

    nom = input("Nom : ")
    while not nom:
        nom = input("Nom : ")

    prenom = input("Prénom : ")
    while not prenom:
        prenom = input("Prénom : ")

    dateNaissance = input("Date de naissance : ")
    while not dateNaissance:
        dateNaissance = input("Date de naissance : ")

    nomAgence = input("Nom de l'agence: ")
    while not nomAgence:
        nomAgence = input("Nom de l'agence: ")

    Agence= '{"nom":"%s"}'%nomAgence

    connexion.requete("INSERT INTO nosql.AgentTechnique VALUES ('%s', '%s', '%s', '%s','%s')"%
    (numsecu, nom, prenom, dateNaissance, Agence))


def modifier_agent():
    print("\n\t--- Quel attribut voulez-vous modifier ? ---")
    print("\n\t0.\tNom")
    print("\n\t1.\tPrénom")
    print("\n\t2.\tdateNaissance")
    print("\n\t3.\tAgence")
    print("\n\t4. \tAnnuler")

    choix = connexion.saisie_nb(0,3)

    if(choix == 0):
        numsecu = input("Quel est votre numéro de sécurité sociale ? : ")
        while not numsecu:
            numsecu = input("Quel est votre numéro de sécurité sociale ? : ")

        agent = connexion.requete("SELECT numsecusociale FROM nosql.AgentTechnique WHERE numsecusociale='%s'"%(numsecu))

        if agent:
            nom = input("Nouveau nom : ")
            while not nom:
                nom = input("Nouveau nom : ")
            connexion.requete("UPDATE nosql.AgentTechnique SET nom = '%s' WHERE numsecusociale = '%s'"%(nom, agent[0][0]))
            sleep(1)
            connexion.screen_clear()

        else:
            print("Erreur dans le numéro de sécurité sociale...")
            sleep(2)

    elif(choix == 1):
        numsecu = input("Quel est votre numéro de sécurité sociale ? : ")
        while not numsecu:
            numsecu = input("Quel est votre numéro de sécurité sociale ? : ")

        agent = connexion.requete("SELECT numsecusociale FROM nosql.AgentTechnique WHERE numsecusociale='%s'"%(numsecu))

        if agent:
            prenom = input("Nouveau prénom : ")
            while not prenom:
                prenom = input("Nouveau prénom : ")
            connexion.requete("UPDATE nosql.AgentTechnique SET prenom = '%s' WHERE numsecusociale = '%s'"%(prenom, agent[0][0]))
            sleep(1)
            connexion.screen_clear()
        else:
            print("Erreur dans le numéro de sécurité sociale...")
            sleep(2)

    elif(choix == 2):
        numsecu = input("Quel est votre numéro de sécurité sociale ? : ")
        while not numsecu:
            numsecu = input("Quel est votre numéro de sécurité sociale ? : ")

        agent = connexion.requete("SELECT numsecusociale FROM nosql.AgentTechnique WHERE numsecusociale='%s'"%(numsecu))

        if agent:
            dateNaissance = input("Nouvelle date de Naissance: ")
            while not dateNaissance:
                dateNaissance = input("Nouvelle date de Naissance : ")
            connexion.requete("UPDATE nosql.AgentTechnique SET datenaissance = '%s' WHERE numsecusociale = '%s'"%(dateNaissance, agent[0][0]))
            sleep(1)
            connexion.screen_clear()
        else:
            print("Erreur dans le numéro de sécurité sociale...")
            sleep(2)

    elif(choix == 3):
        numsecu = input("Quel est votre numéro de sécurité sociale ? : ")
        while not numsecu:
            numsecu = input("Quel est votre numéro de sécurité sociale ? : ")

        agent = connexion.requete("SELECT numsecusociale FROM nosql.AgentTechnique WHERE numsecusociale='%s'"%(numsecu))

        if agent:
            nomagence = input("Nouvelle Agence: ")
            while not nomagence:
                nomagence = input("Nouvelle Agence: ")
            Agence= '{"nom":"%s"}'%nomagence
            connexion.requete("UPDATE nosql.AgentTechnique SET agence = '%s' WHERE numsecusociale = '%s'"%(Agence, agent[0][0]))
            sleep(1)
            connexion.screen_clear()
        else:
            print("Erreur dans le numéro de sécurité sociale...")
            sleep(2)
    elif(choix==4):
        pass

def supprimer_agent():
    numsecu = input("Quel est votre numéro de sécurité sociale ? : ")
    while not numsecu:
        numsecu = input("Quel est votre numéro de sécurité sociale ? : ")
    connexion.requete("DELETE FROM nosql.AgentTechnique  WHERE numsecusociale= '%s'"%(numsecu))
    print("L'agent a bien été désinscrit")
    connexion.screen_clear()



def interrogations():

    print("\nAfficher tous les agents\n")
    connexion.afficher_L_o_L(connexion.requete("SELECT a.numsecusociale, a.nom, a.prenom, a.datenaissance, a.Agence->>'nom' FROM nosql.AgentTechnique a"))


    print("Afficher tous les agents qui appartiennent à une agence demandée \n")
    agence = input("Quelle nom d'agence choissisez-vous ? : ")
    while not agence:
        agence = input("Quelle nom d'agence choissisez-vous ? : ")
    connexion.afficher_L_o_L(connexion.requete("SELECT a.numsecusociale, a.nom, a.prenom, a.datenaissance, a.Agence->>'nom' FROM nosql.AgentTechnique a WHERE a.Agence->>'nom' ='%s'"%(agence)))
    connexion.screen_clear()



menu_agent_technique()

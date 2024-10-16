#!/usr/bin/python3
# coding: utf-8

import re
import psycopg2
from datetime import date
import os
from time import sleep

from psycopg2 import extensions

# The screen clear function
def screen_clear():
   # for mac and linux(here, os.name is 'posix')
   if os.name == 'posix':
      _ = os.system('clear')
   else:
      # for windows platfrom
      _ = os.system('cls')
   # print out some text

def connexion():
    # modèle
    '''
    HOST = "localhost"
    USER = "me"
    PASSWORD = "secret"
    DATABASE = "mydb"
    '''
    # Paul
    '''
    HOST = "tuxa.sme.utc"
    USER = "nf18p071"
    PASSWORD = "D7MxPqso"
    DATABASE = "dbnf18p071"
    '''
    # Jose-Eduardo
    HOST = "tuxa.sme.utc"
    USER = "nf18p064"
    PASSWORD = "FinYlN7P"
    DATABASE = "dbnf18p064"
    try:
        # Open connection
        conn = psycopg2.connect("host=%s dbname=%s user=%s password=%s" % (HOST, DATABASE, USER, PASSWORD))
        return conn

    except (Exception, psycopg2.Error) as error :
        # if the connection did not work
        print("Erreur lors de la connexion à PostgreSQL\n", error)

def insert(requete):
    try:
        # Connexion à la base des données
        conn = connexion()

        # Open a cursor to send SQL commands
        cur = conn.cursor()

        # Execute a SQL INSERT command
        sql = str(requete)
        cur.execute(sql)
        conn.commit()

        # Close connection
        conn.close()

    except (Exception, psycopg2.Error) as error :
        print ("Erreur lors de l'insertion des données (INSERT)\n", error)
        return 0

    finally:
        if conn is not None:
            conn.close()

    return 1

def update(requete):

    try:

        conn = connexion()

        # Open a cursor to send SQL commands
        cur = conn.cursor()

        # Execute a SQL INSERT command
        sql = str(requete)
        cur.execute(sql)
        conn.commit()

        # Close connection
        conn.close()

    except (Exception, psycopg2.Error) as error :
        
        print ("Erreur lors la mise à jour des données (UPDATE)\n", error)
        return 0

    finally:
        if conn is not None:
            conn.close()

    return 1

def select(requete):

    try:

        conn = connexion()

        # Open a cursor to send SQL commands
        cur = conn.cursor()

        # Execute a SQL SELECT command
        sql = str(requete)
        cur.execute(sql)
        # Fetch all data
        raw = cur.fetchall()

        # Close connection
        conn.close()

    except (Exception, psycopg2.Error) as error :

        print ("Erreur lors la lecture des données (SELECT)\n", error)
        return 0

    finally:
        if conn is not None:
            conn.close()

    resultat = []

    for element in raw:
        resultat.append(list(element))

    return resultat

def delete(requete):

    try:

        conn = connexion()

        # Open a cursor to send SQL commands
        cur = conn.cursor()

        # Execute a SQL INSERT command
        sql = str(requete)
        cur.execute(sql)
        conn.commit()

        # Close connection
        conn.close()

    except (Exception, psycopg2.Error) as error :
        
        print ("Erreur lors la suppresion des donées (DELETE)\n", error)
        return 0

    finally:
        if conn is not None:
            conn.close()

    return 1

def requete(requete_chaine):

    resultat = 0
        
    if re.findall("INSERT", requete_chaine):

        resultat = insert(requete_chaine)

    elif re.findall("SELECT", requete_chaine):

        resultat = select(requete_chaine)

    elif re.findall("DELETE", requete_chaine):

        resultat = delete(requete_chaine)

    elif re.findall("UPDATE", requete_chaine):

        resultat = update(requete_chaine)

    return resultat


'''
Afficher List of List, pour afficher le resultat d'un requete sql
Source: https://blog.finxter.com/print-a-list-of-list-in-python/
'''
def afficher_L_o_L(Liste):

    if Liste != 0:

        # Find maximal length of all elements in list
        n = max(len(str(x)) for l in Liste for x in l)
        # Print the rows
        for row in Liste:
            print(''.join(str(x).ljust(n + 2) for x in row))


# saisir un nombre compris entre min et max inclus
def saisie_nb(min, max):
    while True:
            try:
                choice = int(input("\n> ")) 
                if(choice < min or choice > max):
                    print("Le choix n'est pas compris entre", min, " et ", max, "inclus...")
                    continue
                else:
                    screen_clear()
                    # break
                    return choice
            except ValueError:
                print("Veuillez rentrer uniquement des entiers...")  
                continue


# exécute un fichier sql
def exec_file(name):
    try:
        screen_clear()
        conn = connexion()
        conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()

        sqlfile = open(name, 'r')
        cur.execute(sqlfile.read())

        conn.close()
        
    except (Exception, psycopg2.Error) as error :
        print ("Erreur lors de l'exécution du fichier sql\n", error)
        return 0

    finally:
        if conn is not None:
            conn.close()

    return 1
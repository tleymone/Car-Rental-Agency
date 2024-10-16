import webbrowser
import connexion
from clientParticulier import menu_client_part
from client_pro import menu_client_pro
from AgentCommercial import menu_agent_commercial
from AgentTechnique import MenuTechnique

def menu_principal():   

    while True:
        print("\n\t--- Que voulez-vous faire ? ---")
        print("\n\t0.\tQuitter")
        print("\n\t1.\tCréer et remplir la BDD")
        print("\n\t2.\tPrendre le rôle d'un client particulier")
        print("\n\t3.\tPrendre le rôle d'un client professionnel")
        #print("\n\t4.\tPrendre le rôle d'un agent particulier")
        print("\n\t4.\tPrendre le rôle d'un agent commercial")
        print("\n\t5.\tPrendre le rôle d'un agent technique")
        print("\n\t6.\tAccéder au Gitlab du projet")

        choice = connexion.saisie_nb(0,6)

        if(choice == 0):
            print("\n\tFin du programme.")
            break
        elif(choice == 1):
            connexion.screen_clear()

            print("\n\tCette action supprimera les tables et les données déjà existantes. Voulez-vous continuer ?")
            print("\t0.\tNon")
            print("\t1.\tOui")

            choice = connexion.saisie_nb(0,1)

            if(choice):
                connexion.exec_file("creation.sql")
            else:
                print("Action annulée.")

        elif(choice == 2):
            menu_client_part()
        elif(choice == 3):
            menu_client_pro()
        #elif(choice == 7):
        #    pass
        elif(choice == 4):
            menu_agent_commercial()
        elif(choice == 5):
            MenuTechnique()
        elif(choice == 6):
            print("Redirection vers le Gitlab...")
            webbrowser.open('https://gitlab.utc.fr/pmargeri/nf18_projet/', new = 0, autoraise=True)

def main():
    menu_principal()

# Exécution du programme
main()

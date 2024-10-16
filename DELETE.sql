/*    FICHIER DE SUPPRESSION DU SCHEMA CONTENANT LES TABLES    */

/* Membres du groupe :
  * Anaïs Laveau
  * Thomas Leymonerie
  * Jose Eduardo Garcia Beltran
  * Paul-Edouard Margerit
*/

DROP SCHEMA IF EXISTS projet CASCADE;
/* IF EXISTS nous permet de supprimer le schéma uniquement s'il existe */
/* CASCADE nous permet de supprimer le schéma, tous ses objets et les objets qui dépendent de ses objets */

/* Nous n'avons pas besoin de supprimer de tables si l'on supprime le schéma mais */
/*  voici un exemple de suppression de table : */
DROP TABLE IF EXISTS projet.Conducteur CASCADE;	




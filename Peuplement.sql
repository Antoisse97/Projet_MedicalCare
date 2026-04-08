-----------------------------------------------PEUPLEMENT MEDICAL CARE---------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------
--Mise en place du cadre d'étude par création de centre, du personnel : Centre, Personnel, Perso_Med
-----------------------------------P1_PeuplementCentre codé par Antoisse--------------------------------------
CREATE OR REPLACE PROCEDURE PeupleCentre(n in number) as 
BEGIN
    COMMIT;
    DELETE FROM Centre;
    FOR I IN 1..n LOOP
        INSERT INTO CENTRE(ID_CENTRE)
        VALUES (i);
    END LOOP;
END;
/
--call
call PeupleCentre(5);
SELECT * FROM CENTRE;
commit;
--------------------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------------------------------------
-- 03 Avril 2026
--------------------------------------------P3_PeuplementPersonnel (développé par Caleb)-----------------------------------------
CREATE OR REPLACE PROCEDURE PeuplePersonnel (np IN NUMBER) AS
  TYPE t_roles IS VARRAY(7) OF VARCHAR2(30);
  v_roles t_roles := t_roles('Medecin', 'Infirmiere', 'ARC', 'KINE', 'Cardiologue', 'Biologiste','Data-Manager');-- les rôles possibles pour le personnel

  TYPE t_centres IS VARRAY(5) OF NUMBER;
  v_centres t_centres := t_centres(1, 2, 3, 4,5); -- les centres possibles pour le personnel

  TYPE t_identites IS VARRAY(20) OF VARCHAR2(50);
  v_identites t_identites := t_identites(
    'Martin Nathan','Dubois Emma','Bernard Lucas','Thomas Chloé',
    'Robert Hugo','Richard Inès','Petit Adam','Durand Léa',
    'Leroy Noah','Moreau Manon','Simon Louis','Laurent Sarah',
    'Lefebvre Jules','Michel Clara','Garcia Tom','David Camille',
    'Bertrand Lina','Roux Maxime','Vincent Zoé','Fournier Aymeric'
  ); -- Liste d'identités pour le personnel (Format : Nom Prénom)

  v_idCentre    NUMBER; -- variable pour stocker le centre tiré aléatoirement
  v_sonIdentite VARCHAR2(50); -- variable pour stocker l'identité tirée aléatoirement
  v_metier      VARCHAR2(30); -- variable pour stocker le rôle tiré aléatoirement
  v_index       PLS_INTEGER; -- variable pour stocker l'index aléatoire utilisé pour tirer les centres, identités et rôles
  v_nb_arc_centre NUMBER; -- variable pour compter le nombre d'ARC ou Data-Manager déjà présents dans un centre
BEGIN
  FOR i IN 1 .. np LOOP
    -- centre aléatoire
    v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_centres.COUNT + 1)); -- génère un index aléatoire entre 1 et le nombre de centres disponibles
    v_idCentre := v_centres(v_index);

    -- identité aléatoire
    v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_identites.COUNT + 1));
    v_sonIdentite := v_identites(v_index);

    -- rôle aléatoire
    v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_roles.COUNT + 1));
    v_metier := v_roles(v_index);
    
    -- si le rôle tiré est ARC ou Data-Manager, vérifier unicité dans ce centre
    IF v_metier IN ('ARC', 'Data-Manager') THEN
      SELECT COUNT(*)
      INTO v_nb_arc_centre
      FROM PERSONNEL
      WHERE ROLE = v_metier
        AND ID_CENTRE = v_idCentre;
    
      IF v_nb_arc_centre > 0 THEN
        -- un ARC ou Data-Manager existe déjà dans ce centre : on tire un autre rôle (ni ARC ni Data-Manager)
        LOOP
          v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_roles.COUNT + 1));
          v_metier := v_roles(v_index);
          EXIT WHEN v_metier NOT IN ('ARC', 'Data-Manager');
        END LOOP;
      END IF;
    END IF;

    INSERT INTO PERSONNEL (ID_PERSO, ID_CENTRE, NUM_ADELI, NOM, ROLE)
    VALUES (NULL, v_idCentre, NULL, v_sonIdentite, v_metier);
  END LOOP;
END;
/

------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------P4_Peuplement PersoMed (développée par Caleb)-----------------------------------------
CREATE OR REPLACE PROCEDURE PeuplePersoMedical AS -- procédure qui peuple la table perso_med en récupérant les infos du personnel en fonction de son rôle
BEGIN
  FOR p IN (SELECT ID_PERSO, NUM_ADELI, ROLE FROM   PERSONNEL WHERE  ROLE IN ('Medecin','Infirmiere','KINE','Cardiologue','Biologiste')) -- Pour chaque personnel qui a un rôle parmi Médecin, Infirmière, KINE, Cardiologue ou Biologiste, exécute les instructions du LOOP une fois avec ses données dans la variable p
  LOOP
    -- détermination du service en fonction du rôle
    DECLARE
      v_service VARCHAR2(100);
    BEGIN
      IF p.ROLE = 'Cardiologue' THEN
        v_service := 'Electro-encéphalogramme';
      ELSIF p.ROLE = 'Biologiste' THEN
        v_service := 'Prise de sang et des résultats d''analyse';
      ELSIF p.ROLE = 'KINE' THEN
        v_service := 'Test d''effort';
    ELSE
        v_service := NULL; -- pour les rôles qui n'ont pas de service spécifique
      END IF;

      -- insertion dans PERSO_MED
      INSERT INTO PERSO_MED (NUM_ADELI, ID_PERSO, SPECIALITE, SERVICE)
      VALUES (NULL, p.ID_PERSO, p.ROLE, v_service);
    END;
  END LOOP;
END;
/


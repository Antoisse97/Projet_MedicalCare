--trigger uptade de patient après la saisit de son dossier
CREATE OR REPLACE TRIGGER trg_uptadePatient_AprèsSaisitDossier
AFTER INSERT 
ON DOSSIER
FOR EACH ROW 
BEGIN
    UPDATE PATIENT 
    SET LIGNE_DOSSIER = :NEW.LIGNE_DOSSIER
    WHERE ID_PATIENT = :NEW.ID_PATIENT;
END;
/
COMMIT

--numéros adéli 
CREATE OR REPLACE TRIGGER trg_adeli_medecin
BEFORE INSERT ON PERSO_MED
FOR EACH ROW
DECLARE
    v_role PERSONNEL.role%type;
    v_base NUMBER;
BEGIN 
-- récupération du role du personnage 
    SELECT ROLE
    INTO v_role
    FROM PERSONNEL
    WHERE ID_PERSO = :NEW.ID_PERSO;
-- base selon le role 
    IF v_role = 'Medecin' THEN
        v_base :=1000;
    ELSIF v_role = 'Infirmiere' THEN 
        v_base :=2000;
    ELSIF v_role = 'Cardiologue' THEN 
        v_base :=3000;
    ELSIF v_role = 'KINE' THEN 
        v_base :=4000;
    ELSIF v_role = 'Biologiste' THEN 
        v_base :=5000;
    ELSE 
        v_base := 9000; --valeur default
        RAISE_APPLICATION_ERROR(-20010, 'Le role saisit est inconu');
    END IF; 
-- calcul du num adeli 
    :NEW.NUM_ADELI := v_base + :NEW.ID_PERSO;
END;
/
COMMIT;

--trigger uptade numéro adéli  -> Perso_Med après la saisit d'un Personnel
CREATE OR REPLACE TRIGGER trg_uptadePerso_Med_aprèsSaisitPersonnel
AFTER INSERT ON PERSONNEL 
FOR EACH ROW 
BEGIN 
    UPDATE PERSO_MED 
    SET Num_Adeli = :NEW.Num_Adeli
    WHERE Id_Perso = :NEW.Id_Perso;
END; 
/
COMMIT
-- prêt pour être testé 
---- 24 Mars 2026
---- 25 Mars 2026
ALTER TABLE FICHE_QUOTIDIENNE RENAME COLUMN NUMPATIENT TO NUM_JOUR;
--Générer automatiquement NUMLOTS (par concaténation de l’ID_PATIENT et du numéro de jour) plutôt que de le saisir à la main.
CREATE OR REPLACE TRIGGER trg_CalculNumLot  --pret a tester
BEFORE INSERT ON LOT_MEDICAMENT 
FOR EACH ROW
DECLARE 
    v_numJour number;
BEGIN
    --recupération du num de fiche
    SELECT NUM_JOUR
    INTO v_numJour
    FROM FICHE_QUOTIDIENNE
    WHERE ID_PATIENT = :NEW.ID_PATIENT;
    
    -- Calcul du numéros de lot
    :NEW.NUMLOTS := v_numJour * 1000 + :NEW.ID_PATIENT;
END;
/

-- 27 Mars 2026
--Mise en place du cadre d'étude par création de centre, du personnel : Centre, Personnel, Perso_Med
-- P1_PeuplementDebut
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
commit

---------------------------------------------------------------------------------------------------------------------------------
--01 Avril 2026 (Développé par C)
-- Automatisation de la numérotation des tables dont l'identifiant peut être numéroté automatiquement à partir de 1 : 
-- creation d'une sequence de numérotation automatique pour le patient-------------------------------------------------
create sequence NumerotationPatientSeq 
    start with 1 increment by 1; -- Commence la numérotation à 1 mais pour tester on peut modifier le chiffre de départ
    
-- creation d'une sequence de numérotation automatique pour le centre
create sequence NumerotationCentreSeq
    start with 1 increment by 1;

-- creation d'une sequence de numérotation automatique pour le personnel
create sequence NumerotationPersonnelSeq
    start with 1 increment by 1;

-- creation d'une sequence de numérotation automatique pour la fiche quotidienne
create sequence NumerotationFicheQuotidienneSeq
    start with 1 increment by 1;
    
drop sequence NumerotationPersonnelSeq;
----------------------------Trigger d'automatisation de la numérotation du patient----------------------------------------------
create or replace trigger trg_PatientAutoNum
before insert on Patient
for each row
begin 
    If :NEW.Id_Patient is NULL then
        select NumerotationPatientSeq.nextval into :NEW.Id_Patient from dual; -- Insert la valeur à partir de la séquence de numérotation
    end if; 
end; 
-- Pour tester il faut mettre un null à l'emplacement de Id_Patient

------------------------------------Trigger d'automatisation de la numérotation du centre---------------------------
create or replace trigger trg_CentreAutoNum
before insert on Centre
for each row
begin 
    If :NEW.Id_Centre is NULL then
        select NumerotationCentreSeq.nextval into :NEW.Id_Centre from dual; -- Insert la valeur à partir de la séquence de numérotation
    end if; 
end; 
-- Pour tester il faut mettre un null à l'emplacement de Id_Centre

--------------------------Trigger d'automatisation de la numérotation du Personnel 
create or replace trigger trg_PersonnelAutoNum
before insert on Personnel
for each row
begin 
    If :NEW.Id_Perso is NULL then
        select NumerotationPersonnelSeq.nextval into :NEW.Id_Perso from dual; -- Insert la valeur à partir de la séquence de numérotation
    end if;
end; 
-- Pour tester il faut mettre un null à l'emplacement de Id_Perso
/

--------------------------Trigger d'automatisation de la numérotation de la fiche quotidienne 
create or replace trigger trg_FicheQuotidienneAutoNum
before insert on FICHE_QUOTIDIENNE
for each row
begin 
    If :NEW.Num_F is NULL then
        select NumerotationFicheQuotidienneSeq.nextval into :NEW.Num_F from dual; -- Insert la valeur à partir de la séquence de numérotation
    end if;
end; 
-- Pour tester il faut mettre un null à l'emplacement de Id_Perso
/
commit;

---------------------------------------------------------------------------------------------------------------------------------
-- 03 Avril 2026
-----------------------------------Procédure de peuplement du personnel (développé par C)----------------------------------------
CREATE OR REPLACE PROCEDURE PeuplePersonnel (np IN NUMBER) AS
  TYPE t_roles IS VARRAY(7) OF VARCHAR2(30);
  v_roles t_roles := t_roles('Medecin', 'Infirmiere', 'ARC', 'KINE', 'Cardiologue', 'Biologiste','Data-Manager');

  TYPE t_centres IS VARRAY(4) OF NUMBER;
  v_centres t_centres := t_centres(1, 2, 3, 4);

  TYPE t_identites IS VARRAY(20) OF VARCHAR2(50);
  v_identites t_identites := t_identites(
    'Martin Nathan','Dubois Emma','Bernard Lucas','Thomas Chloé',
    'Robert Hugo','Richard Inès','Petit Adam','Durand Léa',
    'Leroy Noah','Moreau Manon','Simon Louis','Laurent Sarah',
    'Lefebvre Jules','Michel Clara','Garcia Tom','David Camille',
    'Bertrand Lina','Roux Maxime','Vincent Zoé','Fournier Aymeric'
  );

  v_idCentre    NUMBER;
  v_sonIdentite VARCHAR2(50);
  v_metier      VARCHAR2(30);
  v_index       PLS_INTEGER;
  v_nb_arc_centre NUMBER;
BEGIN
  FOR i IN 1 .. np LOOP
    -- centre aléatoire
    v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_centres.COUNT + 1));
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

SELECT NumerotationPersonnelSeq.NEXTVAL FROM dual; -- pour afficher le prochain numéro de l'ID_PERSO (num auto)

-----Appel de la procédure----------
call PeuplePersonnel(30); -- Insère 30 personnel

-- 03 Avril 2026
-------------------------------------------Procédure de nettoyage du personnel (développé par C)------------------------------------
-- Procedure permettant d'effacer le contenu à partir d'un nombre de départ 
CREATE OR REPLACE PROCEDURE CleanPersonnel  (debut IN NUMBER, fin IN NUMBER) AS
    v_max Number; 
Begin 
    select count (*) into v_max from Personnel where ID_PERSO between debut and fin; -- on compte le nombre d'élement à supprimer
    if fin - debut + 1 > v_max then -- nombre incohérent
        RAISE_APPLICATION_ERROR(-20040,'Le nombre de personne à supprimer est supérieur au nombre de personnel');
    end if; 
    
    For i in debut..fin loop -- nombre correct
        Delete from Personnel where ID_PERSO = i; -- suppression
    end loop; 
end; 
/
commit;

call CleanPersonnel (2,31);-- (Efface les personnel dont les identifiants sont compris entre 22 et 36,les deux inclus)

commit;

-----------------------------------Procédure de peuplement du personnel médical (développé par C)----------------------------------------
CREATE OR REPLACE PROCEDURE PeuplePersoMedical AS -- procédure qui peuple la table perso_med en récupérant les infos du personnel en fonction de son rôle
BEGIN
  FOR p IN (SELECT ID_PERSO, NUM_ADELI, ROLE FROM   PERSONNEL WHERE  ROLE IN ('Medecin','Infirmiere','KINE','Cardiologue','Biologiste')) -- Pour chaque personnel qui a un rôle parmi Médecin, Infirmière, KINE, Cardiologue ou Biologiste, exécute les instructions du LOOP une fois avec ses données dans la variable p
  LOOP
    -- détermination du service en fonction du rôle
    DECLARE
      v_service VARCHAR2(100);
    BEGIN
      IF p.ROLE = 'Cardiologue' THEN
        v_service := 'Test d''effort';
      ELSIF p.ROLE = 'Biologiste' THEN
        v_service := 'Prise de sang et des résultats d''analyse';
      ELSE
        v_service := 'Electro-encéphalogramme';
      END IF;

      -- insertion dans PERSO_MED
      INSERT INTO PERSO_MED (NUM_ADELI, ID_PERSO, SPECIALITE, SERVICE)
      VALUES (NULL, p.ID_PERSO, p.ROLE, v_service);
    END;
  END LOOP;
END;
/

-- call
call PeuplePersoMedical(); -- Appel de la procédure de peuplement du personnel médical

Delete from Personnel;

------------------ A faire ! pour pouvoir casser les clés étrangères en boucle qu'on avait et qui empêchait le nettoyage des tables-------------
ALTER TABLE PERSONNEL
  DROP CONSTRAINT FK_PERSONNE_EST_SOIGN_PERSO_ME;
ALTER TABLE PATIENT
  DROP CONSTRAINT FK_PATIENT_APPARTIEN_DOSSIER;
DELETE FROM PERSONNEL;

COMMIT; 
---------------------------------------------------------------------------------------------------------------------------------




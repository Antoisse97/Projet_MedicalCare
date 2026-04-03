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

--01 Avril 2026 (Développé par C)
-- Automatisation de la numérotation des tables dont l'identifiant peut être numéroté automatiquement à partir de 1 : 
-- creation d'une sequence de numérotation automatique pour le patient
create sequence NumerotationPatientSeq 
    start with 1 increment by 1; -- Commence la numérotation à 1 mais pour tester on peut modifier le chiffre de départ
    
-- creation d'une sequence de numérotation automatique pour le centre
create sequence NumerotationCentreSeq
    start with 1 increment by 1;

-- creation d'une sequence de numérotation automatique pour le personnel
create sequence NumerotationPersonnelSeq
    start with 11 increment by 1;


-- Trigger d'automatisation de la numérotation du patient 
create or replace trigger trg_PatientAutoNum
before insert on Patient
for each row
begin 
    select NumerotationPatientSeq.nextval into :NEW.Id_Patient from dual; -- Insert la valeur à partir de la séquence de numérotation
end; 
-- Pour tester il faut mettre un null à l'emplacement de Id_Patient

-- Petit test
Insert into Patient values (NULL,1002,NULL,2,'Nathan','Aucun', TO_DATE('05-03-2005','DD-MM-YYYY'),60,180,30,'H','VP',2); 
Insert into Patient values (NULL,1002,NULL,2,'Vroum','Aucun', TO_DATE('05-03-2005','DD-MM-YYYY'),60,180,30,'H','VP',2); 

drop sequence NumerotationAutoSeq;

-- Trigger d'automatisation de la numérotation du centre 
create or replace trigger trg_CentreAutoNum
before insert on Centre
for each row
begin 
    select NumerotationCentreSeq.nextval into :NEW.Id_Centre from dual; -- Insert la valeur à partir de la séquence de numérotation
end; 
-- Pour tester il faut mettre un null à l'emplacement de Id_Centre

Insert into centre values (Null);

-- Trigger d'automatisation de la numérotation du Personnel 
create or replace trigger trg_PersonnelAutoNum
before insert on Personnel
for each row
begin 
    select NumerotationPersonnelSeq.nextval into :NEW.Id_Perso from dual; -- Insert la valeur à partir de la séquence de numérotation
end; 
-- Pour tester il faut mettre un null à l'emplacement de Id_Perso
/
commit;

-- 03 Avril 2026
-- Procédure de peuplement du personnel (développé par C)
CREATE OR REPLACE PROCEDURE PeuplePersonnel (np IN NUMBER) AS
    TYPE t_roles IS VARRAY(6) OF VARCHAR2(30); -- tableau de valeurs pour le role
    v_roles t_roles := t_roles('Medecin', 'Infirmier', 'ARC', 'KINE', 'Cardiologue', 'Biologiste');

    TYPE t_centres IS VARRAY(4) OF NUMBER; -- tableau de valeurs pour le centre
    v_centres t_centres := t_centres(1, 2, 3, 4);

    TYPE t_identites IS VARRAY(20) OF VARCHAR2(50); -- tableau de valeurs pour les identites
    v_identites t_identites := t_identites(
      'Martin Nathan',
      'Dubois Emma',
      'Bernard Lucas',
      'Thomas Chloé',
      'Robert Hugo',
      'Richard Inès',
      'Petit Adam',
      'Durand Léa',
      'Leroy Noah',
      'Moreau Manon',
      'Simon Louis',
      'Laurent Sarah',
      'Lefebvre Jules',
      'Michel Clara',
      'Garcia Tom',
      'David Camille',
      'Bertrand Lina',
      'Roux Maxime',
      'Vincent Zoé',
      'Fournier Aymeric'
    );

    v_idCentre    NUMBER; 
    v_sonIdentite VARCHAR2(50);
    v_metier      VARCHAR2(30);
    v_index       PLS_INTEGER;
BEGIN
    FOR i IN 1..np LOOP -- Boucle 
        v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_centres.COUNT + 1)); -- on choisit une valeur au hasard
        v_idCentre := v_centres(v_index);

        v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_identites.COUNT + 1)); -- on choisit une valeur au hasard
        v_sonIdentite := v_identites(v_index);

        v_index := TRUNC(DBMS_RANDOM.VALUE(1, v_roles.COUNT + 1)); -- on choisit une valeur au hasard
        v_metier := v_roles(v_index);

        INSERT INTO PERSONNEL (ID_PERSO, ID_CENTRE, NUM_ADELI, NOM, ROLE) -- insertion
        VALUES (NULL, v_idCentre, NULL, v_sonIdentite, v_metier);
    END LOOP;
END;
/
commit;

SELECT NumerotationPersonnelSeq.NEXTVAL FROM dual;

--call
call PeuplePersonnel(15); -- Insère 15 personnel

-- 03 Avril 2026
-- Procédure de nettoyage du personnel (développé par C)
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

call CleanPersonnel (22,36); -- (Efface les personnel dont les identifiants sont compris entre 22 et 36,les deux inclus)



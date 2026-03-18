-- C3_PathoExcluante
CREATE OR REPLACE TRIGGER check_Patho_Excluante 
BEFORE INSERT OR UPDATE --avant d'inserer un patient dans la table patient 
ON PATHOLOGIE  
FOR EACH ROW 
BEGIN 
    IF :New.Nom_Patho = 'Peste' OR :New.Nom_Patho = 'Rage' OR :New.Nom_Patho = 'Choléra' THEN  --option2 :  IF :NEW.Nom_Patho IN ('Peste', 'Rage', 'Coléra') THEN
    :NEW.Excluante := 'oui';
    RAISE_APPLICATION_ERROR(-20001, 'La maladie saisit est excluante, le patient ne peu pas être pris dans l''étude');
    END IF;
END;
/
--test pathologie excluante 
insert into PATHOLOGIE VALUES ('Peste', 'oui'); -- l'attribut Excluante n'est pas pertinante, revoir le domain  
insert into PATHOLOGIE VALUES ('Diabète', 'non');
select * from PATHOLOGIE;
--drop trigger check_Patho_Excluante


-------------
--C2_EtatPhysique
CREATE OR REPLACE TRIGGER check_IMC
BEFORE INSERT 
ON PATIENT
FOR EACH ROW
BEGIN
    IF (:New.POIDS / ((:NEW.TAILLE / 100) * (:NEW.TAILLE/ 100))) NOT between 18.5 AND 40 THEN
    RAISE_APPLICATION_ERROR(-20001, 'L''état de forme du patient ne lui permet pas d''intégrer l''étude');
    END IF;
end;
/
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

-- Test ajout patient 

Insert into centre values (1);

Insert into personnel values (1,1,NULL,'François','Medecin');

Update personnel set NUM_ADELI=2345 where ID_PERSO=1 ;

Insert into perso_med values (2345,1,'Medecin',NULL);

Insert into Patient values (1,2345,NULL,1,'Brice','Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'),60,180,30,'H','VP',1); --doit fonctionner

Insert into Patient values (3,2345,NULL,1,'Antoisse','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),160,130,30,'H','VP',1); -- test IMC ne doit pas fonctionner 
Insert into Patient values (3,2345,NULL,1,'Antoisse','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 


--test mise a jour dossier patient antoisse
Insert into Patient values (4,2345,NULL,1,'Caleb','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 
INSERT INTO DOSSIER VALUES (4, 4, 'Neurochirurgie'); 

Insert into Patient values (5,2345,NULL,1,'Ccaleb','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 
INSERT INTO DOSSIER VALUES (5, 5, 'Neurochirurgie'); 

--Contraintes C1_AgeInclusion
CREATE OR REPLACE TRIGGER check_Age_Inclusion
BEFORE INSERT 
ON Patient 
FOR EACH ROW 
BEGIN 
    IF :NEW.DateDeNaissance > TO_DATE('01/01/2008','DD-MM-YYYY') or :NEW.DateDeNaissance < TO_DATE('01/01/1961','DD-MM-YYYY') THEN
    RAISE_APPLICATION_ERROR(-20001, 'L''age du patient ne respecte pas les critères d''inclusions');
    END IF;
END;
/

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
----------------------------------------------
--trigger uptade numéro adéli  -> Perso_Med après la saisit d'un Personnel
CREATE OR REPLACE TRIGGER trg_uptadePerso_Med_aprèsSaisitPersonnel
AFTER INSERT 
ON PERSONNEL 
FOR EACH ROW 
BEGIN 
    UPDATE PERSO_MED 
    SET Num_Adeli = :NEW.Num_Adeli
    WHERE Id_Perso = :NEW.Id_Perso;
END; 

-- prêt pour être testé 
COMMIT;


--trigger qui empêche d'enregistrer un patient dans plus d'un centre
CREATE OR REPLACE TRIGGER CHECK_PATIENT_CENTRE_FIXE
BEFORE UPDATE OF ID_CENTRE ON PATIENT
FOR EACH ROW
BEGIN
  IF :OLD.ID_CENTRE IS NOT NULL AND :NEW.ID_CENTRE <> :OLD.ID_CENTRE THEN -- si l'ancien ID_Centre n'est pas null et que le nouveau ID_centre diffère de l'ancien 
    RAISE_APPLICATION_ERROR(-20021,'Un patient déjà affecté à un centre ne peut pas être transféré dans un autre centre'); -- on refuse car le patient ne peut pas changer de centre au cours de l'étude
  END IF;
END;
/
COMMIT;
-- test 

-- Trigger qui vérifie si le patient est dans le même centre que son médécin référent
CREATE OR REPLACE TRIGGER CHECK_MED_PATIENT_CENTRE
BEFORE INSERT OR UPDATE OF ID_CENTRE, NUM_ADELI ON PATIENT -- avant l'insertion d'un patient dans la table patient, on vérifie le couple d'attrinut Id_centre et Num_Adeli
FOR EACH ROW
DECLARE
  est_present NUMBER;
BEGIN
  -- Ne tester que si les valeurs du médécin et du centre ont été renseigné
  IF :NEW.NUM_ADELI IS NOT NULL AND :NEW.ID_CENTRE IS NOT NULL THEN

    -- On vérifie que le médecin référent est bien rattaché à ce centre
    SELECT COUNT(*)
      INTO est_present
      FROM PERSO_MED pm
           JOIN PERSONNEL p
             ON pm.ID_PERSO = p.ID_PERSO
     WHERE pm.NUM_ADELI = :NEW.NUM_ADELI
       AND p.ID_CENTRE   = :NEW.ID_CENTRE;

    IF est_present = 0 THEN
      RAISE_APPLICATION_ERROR(
        -20040,
        'Le médecin référent n''est pas rattaché au centre du patient : affectation refusée'
      );
    END IF;
  END IF;
END;
/
COMMIT
-- Pour le test on est censé avoir une non insertion du nouveau patient avec le message d'erreur: 'Le médecin référent n'est pas rattaché au centre du patient : affectation refusée'

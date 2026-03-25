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
commit

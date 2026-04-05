---------------Test de la contrainte C3_PathologieExcluante (Codée par Antoisse, testée par Caleb)----------------

-------------------------------------TEST PATHOLOGIE EXCLUANTE----------------------------------------------------
SET SERVEROUTPUT ON; 

BEGIN
  -- On nettoie juste les valeurs de test
  DELETE FROM PATHOLOGIE
  WHERE NOM_PATHO IN ('Peste', 'Diabète');
  COMMIT;
  
  -- CAS 1 : doit être REFUSÉ (Peste)
  BEGIN
    INSERT INTO PATHOLOGIE (NOM_PATHO, EXCLUANTE)
    VALUES ('Peste', 'non');

    DBMS_OUTPUT.PUT_LINE('C3 - ECHEC : Peste a été insérée (elle aurait dû être refusée).');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C3 - OK   : insertion de Peste refusée avec erreur : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  -- CAS 2 : doit être ACCEPTÉ (Diabète)
  BEGIN
    INSERT INTO PATHOLOGIE (NOM_PATHO, EXCLUANTE)
    VALUES ('Diabète', 'non');

    DBMS_OUTPUT.PUT_LINE('C3 - OK   : Diabète a été insérée sans erreur.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C3 - ECHEC : Diabète refusée à tort : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ROLLBACK;  -- on n’enregistre pas les données de test
END;
/
-- Validé par Caleb le 24/03/2026

--------------------------------------------------------------------------------------------
-- Test ajout patient  

Insert into centre values (1);
Insert into personnel values (1,1,NULL,'François','Medecin');
Update personnel set NUM_ADELI=2345 where ID_PERSO=1 ;
Insert into perso_med values (2345,1,'Medecin',NULL);


Insert into Patient values (900,1066,NULL,4,'Bro','Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'),60,180,30,'H','VP',1); --doit fonctionner


------------------Test de la contrainte C2_IMCValide (Codée par Antoisse, testée par Caleb le 24/03/2026)--------------------

------------------------------------------------TEST_IMC_VALIDE--------------------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
  -- CAS 1 : IMC invalide -> doit être refusé
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1003, NULL, 1, 'Antoisse', 'Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'), 160, 130, 30, 'H', 'VP', '1'); -- patient avec IMC anormal
    DBMS_OUTPUT.PUT_LINE('C2 - ECHEC : patient avec IMC invalide inséré.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C2 - OK   : patient avec IMC invalide refusé : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  -- CAS 2 : IMC valide -> doit être accepté
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1003, NULL, 1, 'Antoisse', 'Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'), 60, 180, 30, 'H', 'VP', '1'); -- patient avec IMC normal

    DBMS_OUTPUT.PUT_LINE('C2 - OK   : patient avec IMC valide inséré.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C2 - ECHEC : patient valide refusé : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ROLLBACK;
END;
/


------------------Test de la contrainte C1_AgeInclusion (Codée par Caleb, testée par Antoisse le 24/03/2026)--------------------

---------------------------------------------------TEST_AGE_INCLUSION-----------------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN

  -- CAS 1 : âge invalide -> doit être refusé
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1003, NULL, 1, 'Blaise Karl', 'Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'), 60, 180, 30, 'H', 'VP', '1'); -- patient avec âge non conforme
    DBMS_OUTPUT.PUT_LINE('C1 - ECHEC : patient avec age invalide inséré.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C1 - OK   : patient avec âge invalide refusé : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  -- CAS 2 : âge valide -> doit être accepté
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1003, NULL, 1, 'Antoisse', 'Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'), 60, 180, 30, 'H', 'VP', '1'); -- patient avec âge conforme

    DBMS_OUTPUT.PUT_LINE('C1 - OK   : patient avec âge valide inséré.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C1 - ECHEC : patient valide refusé : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ROLLBACK;
END;
/


-------------------Test de la contrainte CHECK_MED_PATIENT_CENTRE (Codée par Caleb, testée par Antoisse le 24/03/2026)--------------------

----------------------------------------------TEST_COHERENCE_PATIENT_CENTRE---------------------------------------------------------------
SET SERVEROUTPUT ON; 

BEGIN

  ---------------------------------------------------------------------------
  -- Préparation : création d'un patient
  ---------------------------------------------------------------------------

  -- P1 : déjà affecté au centre 1
  INSERT INTO PATIENT VALUES (902, 1003, NULL, 1, 'TestAvecCentre', 'Aucun', DATE '1990-01-01', 70, 175, NULL, 'H', 'TV', NULL);

  COMMIT;


  BEGIN
    UPDATE PATIENT SET ID_CENTRE = 2 WHERE ID_PATIENT = 902;

    DBMS_OUTPUT.PUT_LINE('C6 - ECHEC : patient 902 a changé de centre (il aurait dû être refusé).');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C6 - OK   : refus du transfert du patient 902 comme attendu : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ROLLBACK;  -- on ne garde pas les données de test
-- Validé par Antoisse le 24/03/2026
END;
/


--test mise a jour dossier patient antoisse
Insert into Patient values (4,2345,NULL,1,'Caleb','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 
INSERT INTO DOSSIER VALUES (4, 4, 'Neurochirurgie'); 

Insert into Patient values (5,2345,NULL,1,'Ccaleb','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 
INSERT INTO DOSSIER VALUES (5, 5, 'Neurochirurgie');




------------------- Test de la contrainte CHECK_MED_PATIENT_CENTRE (codée par Caleb, testée par Antoisse le 24/03/2026)--------------------

-----------------------------------------------TEST_COHERENCE_MED_PATIENT---------------------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
  ---------------------------------------------------------------------------
  -- CAS 1 : patient contrôle (centre cohérent avec le médecin) -> doit passer
  ---------------------------------------------------------------------------
  BEGIN
    INSERT INTO PATIENT VALUES (NULL, 1003, NULL, 1, 'Zaza', 'Aucun', TO_DATE('05-03-2001','DD-MM-YYYY'),60, 180, 30, 'H', 'VP', 1);
    DBMS_OUTPUT.PUT_LINE('C7 - OK   : patient (Zaza) accepté avec médecin 1003 au centre 1.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C7 - ECHEC : patient Zaza refusé à tort : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ---------------------------------------------------------------------------
  -- CAS 2 : patient crash test (centre incohérent avec le médecin) -> doit être refusé
  ---------------------------------------------------------------------------
  BEGIN
    INSERT INTO PATIENT VALUES (NULL, 1003, NULL, 4, 'Zozo', 'Aucun', TO_DATE('05-03-2002','DD-MM-YYYY'), 60, 180, 30, 'H', 'VP', 1);
    DBMS_OUTPUT.PUT_LINE('C7 - ECHEC : patient (Zozo) a été inséré alors qu''il aurait dû être refusé.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C7 - OK   : patient (Zozo) refusé comme attendu : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ROLLBACK;  -- on ne garde rien en base
END;
/

---- 24 Mars 2026
--------------------------Test de la contrainte CHECK_UNE_FICHE_JOUR_PAR_PATIENT (Codée par Caleb, testé par Antoisse le 24/03/2026)--------------------

----------------------------------------------------TEST_FICHE_QUOTIDIENNE_UNIQUE------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
  -- Nettoyage des données de test
  DELETE FROM FICHE_QUOTIDIENNE WHERE ID_PATIENT = 900 AND DATEJ = TO_DATE('24-03-2026','DD-MM-YYYY');
  COMMIT;

  ---------------------------------------------------------------------------
  -- CAS 1 : 1ère fiche du patient 900 le 24/03/2026 -> doit ÊTRE ACCEPTÉE
  ---------------------------------------------------------------------------
  BEGIN
    INSERT INTO FICHE_QUOTIDIENNE VALUES (NULL, 900, 22, 10, 80, 180, 190, 37, 'le patient se porte bien et répond bien au medicament', 'le patient est ok', TO_DATE('24-03-2026','DD-MM-YYYY'));
    DBMS_OUTPUT.PUT_LINE('C8 - OK   : 1ère fiche pour patient 900 le 24/03/2026 acceptée.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C8 - ECHEC : 1ère fiche pour patient 900 refusée : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ---------------------------------------------------------------------------
  -- CAS 2 : 2e fiche pour le MÊME patient 900 et la MÊME date -> doit ÊTRE REFUSÉE
  ---------------------------------------------------------------------------
  BEGIN
  INSERT INTO FICHE_QUOTIDIENNE VALUES (NULL, 900, 22, 10, 80, 180, 190, 37, 'le patient se porte bien et répond bien au medicament', 'le patient est ok', TO_DATE('24-03-2026','DD-MM-YYYY'));
    DBMS_OUTPUT.PUT_LINE('C8 - ECHEC : 2e fiche pour patient 900 le 24/03/2026 a été insérée (aurait dû être refusée).');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C8 - OK   : 2e fiche pour patient 900 refusée comme attendu : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ROLLBACK;  -- on ne garde pas les données de test
END;
/
-- Trigger validé // Testé par Antoisse le 24/03/2026

--------------------------Test du trigger trg_adeli_medecin (Codée par Antoisse, testé par Caleb le 24/03/2026)--------------------

--------------------------------------------------TEST_TRIGGER_ADELI_MEDICAL-------------------------------------------------------

SET SERVEROUTPUT ON;
DECLARE
  v_num_adeli PERSO_MED.NUM_ADELI%TYPE;
BEGIN
  -- Nettoyage des données de test
  DELETE FROM PERSO_MED
  WHERE ID_PERSO IN (3,4,5,6,7,8);

  DELETE FROM PERSONNEL
  WHERE ID_PERSO IN (3,4,5,6,7,8);

  COMMIT;

  ---------------------------------------------------------------------------
  -- 1) Préparation : insertion des PERSONNEL selon leur rôle
  ---------------------------------------------------------------------------
  INSERT INTO PERSONNEL VALUES (3, 1, NULL, 'Paul',  'Medecin');

  INSERT INTO PERSONNEL VALUES (4, 1, NULL, 'Julie', 'Infirmiere');

  INSERT INTO PERSONNEL VALUES (5, 1, NULL, 'Marthe','Cardiologue');

  INSERT INTO PERSONNEL VALUES (6, 1, NULL, 'Jean',  'KINE');

  INSERT INTO PERSONNEL VALUES (7, 1, NULL, 'Karl',  'Biologiste');

  INSERT INTO PERSONNEL VALUES (8, 1, NULL, 'Brice', 'ARC');

  COMMIT;

  ---------------------------------------------------------------------------
  -- 2) Tests des rôles avec NUM_ADELI calculé
  ---------------------------------------------------------------------------

  -- Medecin : base 1000 -> 1000 + 3 = 1003
  INSERT INTO PERSO_MED VALUES (NULL, 3, 'Medecin', NULL);
  SELECT NUM_ADELI INTO v_num_adeli FROM PERSO_MED WHERE ID_PERSO = 3;
  DBMS_OUTPUT.PUT_LINE('A1 - Medecin : NUM_ADELI attendu = 1003, obtenu = ' || v_num_adeli);

  -- Infirmiere : base 2000 -> 2000 + 4 = 2004
  INSERT INTO PERSO_MED VALUES (NULL, 4, 'Infirmiere', NULL);
  SELECT NUM_ADELI INTO v_num_adeli FROM PERSO_MED WHERE ID_PERSO = 4;

  DBMS_OUTPUT.PUT_LINE('A1 - Infirmiere : NUM_ADELI attendu = 2004, obtenu = ' || v_num_adeli);

  -- Cardiologue : 3000 + 5 = 3005
  INSERT INTO PERSO_MED VALUES (NULL, 5, 'Cardiologue', NULL);
  SELECT NUM_ADELI INTO v_num_adeli FROM PERSO_MED WHERE ID_PERSO = 5;
  DBMS_OUTPUT.PUT_LINE('A1 - Cardiologue : NUM_ADELI attendu = 3005, obtenu = ' || v_num_adeli);

  -- KINE : 4000 + 6 = 4006
  INSERT INTO PERSO_MED VALUES (NULL, 6, 'KINE', NULL);
  SELECT NUM_ADELI INTO v_num_adeli FROM PERSO_MED WHERE ID_PERSO = 6;
  DBMS_OUTPUT.PUT_LINE('A1 - KINE : NUM_ADELI attendu = 4006, obtenu = ' || v_num_adeli);

  -- Biologiste : 5000 + 7 = 5007
  INSERT INTO PERSO_MED VALUES (NULL, 7, 'Biologiste', NULL);
  SELECT NUM_ADELI INTO v_num_adeli FROM PERSO_MED WHERE ID_PERSO = 7;
  DBMS_OUTPUT.PUT_LINE('A1 - Biologiste : NUM_ADELI attendu = 5007, obtenu = ' || v_num_adeli);

  ---------------------------------------------------------------------------
  -- 3) Cas ARC : doit LEVER l'erreur -20010 (rôle inconnu)
  ---------------------------------------------------------------------------
  BEGIN
    INSERT INTO PERSO_MED VALUES (NULL, 8, 'ARC', NULL);
    DBMS_OUTPUT.PUT_LINE('A1 - ECHEC : insertion ARC acceptée alors qu''elle devait être refusée.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('A1 - OK   : insertion ARC refusée avec erreur : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ROLLBACK;  -- on ne garde pas les données de test
END;
/
-- Trigger validé // Testé par Caleb le 24/03/2026


ALTER TABLE FICHE_EXAM RENAME COLUMN NUMJ TO NUM_F; -- petite modification pour la cohérence entre les tables


----------------------Test de la contrainte Check_ExamCoherentAvecJour (Codée par Antoisse, testée par Caleb le 25/03/2026)--------------------

--------------------------------------------------TEST_COHERENCE_EXAM_JOUR------------------------------------------------
SET SERVEROUTPUT ON;

BEGIN
  ---------------------------------------------------------------------------
  -- Préparation : création d'une fiche quotidienne pour le patient 900 le 19/03/2026
  ---------------------------------------------------------------------------
  INSERT INTO FICHE_QUOTIDIENNE VALUES (4, 900, 22, 10, 80, 180, 190, 37, 'le patient se porte bien et répond bien au medicament', 'le patient est ok', TO_DATE('19-03-2026','DD-MM-YYYY'));
  COMMIT;

  ---------------------------------------------------------------------------
  -- CAS 1 : DATEPRESCRIPTION différente de DATEJ -> doit ÊTRE REFUSÉ
  ---------------------------------------------------------------------------
  BEGIN
    INSERT INTO FICHE_EXAM VALUES (1, NULL, NULL, 4, NULL,'Analyse de sang',TO_DATE('20-03-2026','DD-MM-YYYY'), 1, TO_DATE('20-03-2026','DD-MM-YYYY'));
    DBMS_OUTPUT.PUT_LINE('C9 - ECHEC : cas1 inséré alors qu''il devait être refusé.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C9 - OK   : cas1 refusé comme attendu : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ---------------------------------------------------------------------------
  -- CAS 2 : DATEPRESCRIPTION = DATEJ mais DATEREALISATION < DATEJ -> REFUS
  ---------------------------------------------------------------------------
  BEGIN
    INSERT INTO FICHE_EXAM VALUES (2, NULL, NULL, 4, NULL, 'Analyse de sang', TO_DATE('19-03-2026','DD-MM-YYYY'), 1, TO_DATE('18-03-2026','DD-MM-YYYY'));
    DBMS_OUTPUT.PUT_LINE('C9 - ECHEC : cas2 inséré alors qu''il devait être refusé.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C9 - OK   : cas2 refusé comme attendu : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ---------------------------------------------------------------------------
  -- CAS 3 : dates cohérentes -> doit ÊTRE ACCEPTÉ
  -- DATEPRESCRIPTION = DATEJ = 19/03/2026, DATEREALISATION >= DATEJ
  ---------------------------------------------------------------------------
  BEGIN
    INSERT INTO FICHE_EXAM VALUES (3, NULL, NULL, 4, NULL, 'Analyse de sang', TO_DATE('19-03-2026','DD-MM-YYYY'), 1, TO_DATE('20-03-2026','DD-MM-YYYY'));

    DBMS_OUTPUT.PUT_LINE('C9 - OK   : cas3 (dates cohérentes) inséré comme attendu.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C9 - ECHEC : cas3 (cohérent) refusé : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;
-- Trigger validé // Testé par Caleb le 25/03/2026
  ROLLBACK;  -- on ne garde pas les données de test
END;
/
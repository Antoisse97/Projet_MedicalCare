---------------Test de la contrainte C3_PathologieExcluante (Codée par Antoisse, testée par Caleb)--------------------
---------------TEST PATHOLOGIE EXCLUANTE--------------------
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
--------------------TEST_IMC_VALIDE---------------
SET SERVEROUTPUT ON;

BEGIN
  -- CAS 1 : IMC invalide -> doit être refusé
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1066, NULL, 4, 'Antoisse', 'Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'), 160, 130, 30, 'H', 'VP', '1'); -- patient avec IMC anormal
    DBMS_OUTPUT.PUT_LINE('C2 - ECHEC : patient avec IMC invalide inséré.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C2 - OK   : patient avec IMC invalide refusé : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  -- CAS 2 : IMC valide -> doit être accepté
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1066, NULL, 4, 'Antoisse', 'Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'), 60, 180, 30, 'H', 'VP', '1'); -- patient avec IMC normal

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
--------------------TEST_AGE_INCLUSION---------------
SET SERVEROUTPUT ON;

BEGIN

  -- CAS 1 : âge invalide -> doit être refusé
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1066, NULL, 4, 'Blaise Karl', 'Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'), 60, 180, 30, 'H', 'VP', '1'); -- patient avec âge non conforme
    DBMS_OUTPUT.PUT_LINE('C1 - ECHEC : patient avec age invalide inséré.');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C1 - OK   : patient avec âge invalide refusé : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  -- CAS 2 : âge valide -> doit être accepté
  BEGIN
    INSERT INTO PATIENT (ID_PATIENT, NUM_ADELI, LIGNE_DOSSIER, ID_CENTRE, NOM, TRAITEMENT, DATEDENAISSANCE, POIDS, TAILLE, IMC, SEXE, GROUPE, SOUS_GROUPE)
    VALUES (NULL, 1066, NULL, 4, 'Antoisse', 'Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'), 60, 180, 30, 'H', 'VP', '1'); -- patient avec âge conforme

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
---------------------------TEST_COHERENCE_PATIENT_CENTRE-----------------------------
--------------------
SET SERVEROUTPUT ON;

BEGIN

  ---------------------------------------------------------------------------
  -- Préparation : création de 2 patients
  ---------------------------------------------------------------------------
  -- P1 : sans centre au départ (ID_CENTRE NULL)
  INSERT INTO PATIENT VALUES (901, 1066, NULL, 4, 'TestSansCentre', 'Aucun', DATE '1990-01-01', 70, 175, NULL, 'H', 'TV', NULL);

  -- P2 : déjà affecté au centre 4
  INSERT INTO PATIENT VALUES (902, 1066, NULL, 4, 'TestAvecCentre', 'Aucun', DATE '1990-01-01', 70, 175, NULL, 'H', 'TV', NULL);

  COMMIT;

  ---------------------------------------------------------------------------
  -- CAS 1 : passage de NULL -> 4 (doit ÊTRE ACCEPTÉ)
  ---------------------------------------------------------------------------
  BEGIN
    UPDATE PATIENT SET ID_CENTRE = 4 WHERE ID_PATIENT = 901;

    DBMS_OUTPUT.PUT_LINE('C6 - OK   : patient 901 est passé de NULL à centre 4 (autorisé).');
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('C6 - ECHEC : patient 901 refusé à tort : '
                           || SQLCODE || ' - ' || SQLERRM);
  END;

  ---------------------------------------------------------------------------
  -- CAS 2 : passage de 4 -> 2 (doit ÊTRE REFUSÉ)
  ---------------------------------------------------------------------------
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

-- test 
-- insertion d'un patient dans un centre
Insert into centre values (2);
Insert into Patient values (5,2345,NULL,1,'Brauwn','Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'),60,180,30,'H','VP',1); --doit fonctionner
INSERT INTO DOSSIER VALUES (5, 5, 'Neurochirurgie'); 
-- insertion du même patient dans un autre centre (ici centre 2) 
Update PATIENT set ID_CENTRE = 2 where ID_PATIENT=5 ; -- fonctionne  
-- Validé

-- CHECK_MED_PATIENT_CENTRE
-- Pour le test on est censé avoir une non insertion du nouveau patient
-- creation d'un nouveau medecin
Insert into centre values (2);
Insert into personnel values (5,2,NULL,'Dupont','Medecin');
Insert into perso_med values (4345,5,'Medecin',NULL);

-- insertion d'un nouveau patient contrôle 
Insert into Patient values (6,1005,NULL,2,'Zaza','Aucun', TO_DATE('05-03-2001','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 
INSERT INTO DOSSIER VALUES (6, 6, 'Neurochirurgie'); 
-- insertion du patient crash test 
Insert into Patient values (7,1005,NULL,1,'Zozo','Aucun', TO_DATE('05-03-2002','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 
INSERT INTO DOSSIER VALUES (7, 7, 'Neurochirurgie'); 

---- 24 Mars 2026
--------------------------Test de la contrainte CHECK_UNE_FICHE_JOUR_PAR_PATIENT (Codée par Caleb, testé par Antoisse le 24/03/2026)--------------------
------------ Une seule fiche quotidienne pour un patient par le même jour
insert into FICHE_QUOTIDIENNE VALUES (1,5,22,10,80,180,190,37,'le patient se porte bien et répond bien au medicament', 'le patient est ok', to_date('24-03-2026','DD-MM-YYYY')); -- (RA: doit fonctionner)(RO: Insertion validé => Validé)
insert into FICHE_QUOTIDIENNE VALUES (1,5,22,10,80,180,190,37,'le patient est malade', 'le patient n''est pas ok', to_date('24-03-2026','DD-MM-YYYY')); -- (RA: ne doit pas fonctionner)(RO: Insertion refusée => Validé)
-- Trigger validé // Testé par Antoisse le 24/03/2026

--------------------------Test du trigger trg_adeli_medecin (Codée par Antoisse, testé par Caleb le 24/03/2026)--------------------
-- Insertion des personnels médicales selon leur rôle
INSERT INTO PERSONNEL VALUES (3,1,NULL,'Paul','Medecin') ;
INSERT INTO PERSONNEL VALUES (4,1,NULL,'Julie','Infirmiere');
INSERT INTO PERSONNEL VALUES (5,1,NULL,'Marthe','Cardiologue');
INSERT INTO PERSONNEL VALUES (6,1,NULL,'Jean','KINE');
INSERT INTO PERSONNEL VALUES (7,1,NULL,'Karl','Biologiste');
INSERT INTO PERSONNEL VALUES (8,1,NULL,'Brice','ARC');
-- Le numéro adeli doit être mis à jour automatiquement selon la logique du métier concerné// Résultat attendu : RA et Résultat obtenu : RO
-- Pour le médécin 
INSERT INTO PERSO_MED VALUES (3,3,'Medecin',NULL); -- (RA :1000 + ID perso donc => 1003)(RO: 1003 => Validé)
-- Pour l'Infirmiere 
INSERT INTO PERSO_MED VALUES (4,4,'Infirmiere',NULL); -- (RA :2000 + ID perso donc => 2004)(RO: 2003 => Validé)
-- Pour le Cardiologue 
INSERT INTO PERSO_MED VALUES (5,5,'Cardiologue',NULL); -- (RA :3000 + ID perso donc => 3005)(RO: 3005 => Validé)
-- Pour le Kiné 
INSERT INTO PERSO_MED VALUES (6,6,'KINE',NULL); -- (RA :4000 + ID perso donc => 4006)(RO: 4006 => Validé)
-- Pour le Biologiste 
INSERT INTO PERSO_MED VALUES (7,7,'Biologiste',NULL); -- (RA :5000 + ID perso donc => 5007)(RO: 5007 => Validé)
-- Test pour l'arc normalement cela lève une erreur car il ne peut pas avoir de num adeli
INSERT INTO PERSO_MED VALUES (8,8,'ARC',NULL); -- (RA :Message d'erreur "Le rôle saisit est inconnu" => Pas de mise à jour ni d'insertion)(RO: Pas d'insertion + message d'erreur => Validé)
-- Trigger validé // Testé par Caleb le 24/03/2026
COMMIT; 
/

ALTER TABLE FICHE_EXAM RENAME COLUMN NUMJ TO NUM_F; -- petite modification pour la cohérence entre les tables

---- 25 Mars 2026
-----------------------------Test du trigger trg_ExamCoherentAvecJour (Codé par Antoisse, testé par Caleb le 25/03/2026)-------------------
-- Test du trigger trg_ExamCoherentAvecJour (contrainte de cohérence des dates de la fiche quotidienne) 
-- Résultat attendu : RA et Résultat obtenu : RO
-- Test avec des dates pas cohérentes (La date de prescription dans la fiche quotidienne 1 est 19/03/2026 alors que la date de prescription qu'on a renseigné ici est différente)
INSERT INTO FICHE_EXAM VALUES (1,NULL,NULL,1,NULL,'Analyse de sang',TO_DATE ('20-03-2026','DD-MM-YYYY'),1,TO_DATE ('20-03-2026','DD-MM-YYYY')); -- (RA :Message d'erreur disant que les dates ne sont pas cohérentes)(RO: La date du jour n'est pas cohérente avec les dates de prescription et de réalisation => Validé)
-- Test avec une date incohérente (La date de prescription dans la fiche quotidienne 1 est 19/03/2026 est même date de prescription de la fiche exam mais la date de réalisation est inférieur à celle de prescription (c'est pas cohérent))
INSERT INTO FICHE_EXAM VALUES (3,NULL,NULL,1,NULL,'Analyse de sang',TO_DATE ('19-03-2026','DD-MM-YYYY'),1,TO_DATE ('18-03-2026','DD-MM-YYYY')); -- (RA :Message d'erreur disant que les  dates ne sont pas cohérentes)(RO: La date du jour n'est pas cohérente avec les dates de prescription et de réalisation => Validé)
-- Test avec des dates cohérentes (La date de prescription dans la fiche quotidienne 1 est 19/03/2026 et la date de prescription qu'on a renseigné ici est la même)
INSERT INTO FICHE_EXAM VALUES (3,NULL,NULL,1,NULL,'Analyse de sang',TO_DATE ('19-03-2026','DD-MM-YYYY'),1,TO_DATE ('20-03-2026','DD-MM-YYYY')); -- (RA :Insertion validée)(RO: 1 ligne inséré => Validé)
-- Trigger validé // Testé par Caleb le 25/03/2026
COMMIT; 
/

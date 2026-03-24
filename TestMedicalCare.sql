--test pathologie excluante 
insert into PATHOLOGIE VALUES ('Peste', 'oui'); -- l'attribut Excluante n'est pas pertinante, revoir le domain  
insert into PATHOLOGIE VALUES ('Diabète', 'non');
select * from PATHOLOGIE;
-- Validé

-- Test ajout patient 

Insert into centre values (1);
Insert into personnel values (1,1,NULL,'François','Medecin');
Update personnel set NUM_ADELI=2345 where ID_PERSO=1 ;
Insert into perso_med values (2345,1,'Medecin',NULL);
Insert into Patient values (1,2345,NULL,1,'Brice','Aucun', TO_DATE('05-03-2006','DD-MM-YYYY'),60,180,30,'H','VP',1); --doit fonctionner

Insert into Patient values (3,NULL,1,'Antoisse','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),160,130,30,'H','VP',1); -- test IMC ne doit pas fonctionner 
Insert into Patient values (3,2345,NULL,1,'Antoisse','Aucun', TO_DATE('05-03-2010','DD-MM-YYYY'),60,180,30,'H','VP',1); -- doit fonctionner 


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

-- Test du trigger trg_adeli_medecin (Codé par A, testé par C le 24/03/2026)
-- Insertion des personnels médicales selon leur rôle
INSERT INTO PERSONNEL VALUES (3,1,NULL,'Paul','Medecin') ;
INSERT INTO PERSONNEL VALUES (4,1,NULL,'Julie','Infirmiere');
INSERT INTO PERSONNEL VALUES (5,1,NULL,'Marthe','Cardiologue');
INSERT INTO PERSONNEL VALUES (6,1,NULL,'Jean','KINE');
INSERT INTO PERSONNEL VALUES (7,1,NULL,'Karl','Biologiste');
INSERT INTO PERSONNEL VALUES (8,1,NULL,'Brice','ARC');
-- Le numéro adeli doit être mis à jour automatique selon la logique du métier concerné// Résultat attendu : RA et Résultat obtenu : RO
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
COMMIT; 
/
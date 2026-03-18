--test pathologie excluante 
insert into PATHOLOGIE VALUES ('Peste', 'oui'); -- l'attribut Excluante n'est pas pertinante, revoir le domain  
insert into PATHOLOGIE VALUES ('Diabète', 'non');
select * from PATHOLOGIE;

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
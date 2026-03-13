--Question 7.4.1 Créez deux tables A et B. A comporte les colonnes a (entier), b (alphanumérique)
--et c (entier) ; B comporte les colonnes a (entier) et d (alphanumérique).
drop table TableA cascade constraints;
create table TableA
(
a number,
b varchar2(10) null,
c number null
);

DROP TABLE TableB CASCADE CONSTRAINTS;
CREATE TABLE TableB
(
a NUMBER,
d VARCHAR(2) NULL
);


ALTER TABLE TableB
  MODIFY a NOT NULL;

ALTER TABLE TableB
  ADD CONSTRAINT table_a_uniq UNIQUE (a);
  
--test des triggers
CREATE OR REPLACE PROCEDURE PeupleTableA (n in number) as
BEGIN
    COMMIT;
    DELETE FROM TableA;
    FOR I IN 1..n LOOP 
        INSERT INTO TableA(a,b,c) 
        VALUES(
        i,
        DBMS_RANDOM.STRING('U',5), --5 lettre maj au hasard
        TRUNC(DBMS_RANDOM.VALUE(0, 20)) --entier en 1 et 20
        );
    END LOOP;
END;
/        

--call
EXECUTE PeupleTableA(10);
SELECT * FROM TableA;

--Question 7.4.3 En utilisant un ou plusieurs triggers, programmez la contrainte suivante : 
--une valeur enregistrée dans A.a est nécessairement présente dans B.a
--logique de clé étrangaire 
--V2 : modification faite dans B.a doive être automatiquement faite dans A.a
CREATE OR REPLACE TRIGGER trg_A_a_in_B
BEFORE INSERT OR UPDATE OF a ON TableA
FOR EACH ROW
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO   v_cnt  -- on stock le nombre de fois qu'on a trouver la valeur
  FROM   TableB
  WHERE  a = :NEW.a;
 
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Valeur de A.a absente de B.a');
  END IF;
END;
/
--Si v_cnt = 0 → la valeur n’existe pas dans B.a, on lève une erreur.
--Si v_cnt > 0 → au moins une ligne existe dans B avec cette valeur, on laisse passer l’INSERT/UPDATE

-- valeur supprimer dans B.a est automatiquement supprimé dans les autres tables de A.a
CREATE OR REPLACE TRIGGER trg_no_delete_B_if_used_in_A
BEFORE DELETE ON TableB
FOR EACH ROW
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO   v_cnt
  FROM   TableA
  WHERE  a = :OLD.a;   -- valeur qu’on essaie de supprimer dans B.a

  IF v_cnt > 0 THEN
    RAISE_APPLICATION_ERROR(
      -20020,
      'Impossible de supprimer cette valeur de B.a : elle est encore présente dans A.a'
    );
  END IF;
END;
/

--MISE à JOUR EN CASCADE : ajout
CREATE OR REPLACE TRIGGER trg_cascade_update_A_from_B
AFTER UPDATE OF a ON TableB
FOR EACH ROW
BEGIN
  UPDATE TableA
  SET    a = :NEW.a
  WHERE  a = :OLD.a;
END;
/

CREATE OR REPLACE TRIGGER trg_cascade_suppUptade_A_from_B
AFTER DELETE ON TableB
FOR EACH ROW
BEGIN 
    DELETE FROM TableA
    WHERE a = :OLD.a;
END;
/ 

SELECT * FROM TableA;

commit;
--
-- exemple d'un trigger dans medicalcare
CREATE OR REPLACE TRIGGER trg_PatientEtMedecin_in_Centre
BEFORE INSERT IDPatient ON CENTRE
FOR EACH ROW
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*)
  INTO   v_cnt  -- on stock le nombre de fois qu'on a trouver la valeur
  FROM   CENTRE
  WHERE  Personne. = 
 
  IF v_cnt = 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Valeur de A.a absente de B.a');
  END IF;
END;
/
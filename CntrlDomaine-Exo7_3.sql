--Question 7.3.1 Supprimez MaTable, puis re-créez là, de façon qu'elle comporte trois colonnes de
--type numérique : Id, Taille et Poids.
--On se propose de renseigner les tailles en cm et les poinds en kg. L'intervalle des valeurs admissibles 
--pour les tailles va de 40cm à 250cm. Pour les poids, il va de 2kg à 300kg.
drop table MaTable cascade constraints;
create table MaTable
(
Id number not null,
Taille_cm number not null
CONSTRAINT chk_taille
    CHECK (Taille_cm BETWEEN 40 AND 250),
Poids_kg number not null
CONSTRAINT chk_poids 
    CHECK (Poids_kg BETWEEN 2 AND 300)
);
-- test taille/pds admisible
insert into MaTable values (1,45,80);
-- test taille/pds inadmisible
--insert into MaTable values (1,10,10); FAIT
--7.3.4
ALTER TABLE MaTable DROP CONSTRAINT CHK_TAILLE;
ALTER TABLE MaTable DROP CONSTRAINT CHK_POIDS;
insert into MaTable values (1,10,10);
SELECT * FROM MaTable;
TRUNCATE TABLE MaTable; -- vide ma table

--7.3.5 trigger (déclancheur)
CREATE OR REPLACE TRIGGER check_Taille_Poids
BEFORE INSERT --contrôle l'automatisation sur les les lignes manipulées
ON MaTable
FOR EACH ROW -- autorise l'accès aux xhamps de la ligne insérée
BEGIN 
    IF :NEW.Taille_cm < 40 OR  :NEW.Taille_cm > 250 THEN 
    RAISE_APPLICATION_ERROR(-20001, 'La taille saisie n''est pas dans l''intervalle'); 
    END IF;
    IF :NEW.Poids_kg < 2 OR :NEW.Poids_kg > 300 THEN
    RAISE_APPLICATION_ERROR(20002, 'Le poids saisie n''est pas bon');
    END IF;
end;
/
--test du trigger
insert into MaTable values (9,43,1);
insert into MaTable values (10,45,110);
select * from MaTable; 

commit;
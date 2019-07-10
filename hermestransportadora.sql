/*Comandos de criação de tabela em SQL*/

DROP SCHEMA IF EXISTS transportadora CASCADE;
CREATE SCHEMA transportadora;
SET SCHEMA 'transportadora';

CREATE TABLE rot_rota (
	int_id_pk			SERIAL PRIMARY KEY,
	str_origem 			VARCHAR(30) NOT NULL,
	str_destino			VARCHAR(30) NOT NULL
);
COMMENT ON TABLE rot_rota IS 'possiveis rotas para caminhoes';

COMMENT ON COLUMN rot_rota.int_id_pk IS 'numero identificador';
COMMENT ON COLUMN rot_rota.str_origem IS 'local de origem';
COMMENT ON COLUMN rot_rota.str_destino IS 'local de destino';

ALTER TABLE rot_rota
	ADD CONSTRAINT diferenca_destino_origem
		CHECK( str_origem != str_destino);

CREATE TABLE sub_subrota(
	int_id_sub_rota_pkfk		INTEGER,
	int_id_rota_principal_pkfk	INTEGER,
	PRIMARY KEY(int_id_sub_rota_pkfk,int_id_rota_principal_pkfk),
	FOREIGN KEY(int_id_rota_principal_pkfk) REFERENCES rot_rota(int_id_pk),
	FOREIGN KEY(int_id_sub_rota_pkfk)REFERENCES rot_rota(int_id_pk)
);
ALTER TABLE sub_subrota
	ADD CONSTRAINT subrota_diferente_de_rota
		CHECK(int_id_sub_rota_pkfk != int_id_rota_principal_pkfk);
		
COMMENT ON TABLE sub_subrota IS 'Relacoes entre rotas';

COMMENT ON COLUMN sub_subrota.int_id_sub_rota_pkfk IS 'id da subrota';
COMMENT ON COLUMN sub_subrota.int_id_rota_principal_pkfk IS 'id da rota principal';


CREATE TYPE TIPOCAM AS ENUM('VUC','SEMP','P');
CREATE TABLE cam_caminhao(
	str_chassi_pk		VARCHAR(17) PRIMARY KEY,
	str_placa  			VARCHAR(7) NOT NULL,
	str_marca  			VARCHAR(30) NOT NULL,
	str_cor    			VARCHAR(30) NOT NULL,
	str_tipo   			TIPOCAM NOT NULL,
	int_volume			INTEGER NULL,
	int_capacidade		INTEGER NULL,
	dat_inclusao 		TIMESTAMP NOT NULL DEFAULT now()
);
ALTER TABLE cam_caminhao
	ADD CONSTRAINT valida_dimensoes
		CHECK( int_volume >= 0 AND int_capacidade >= 0);
		
COMMENT ON TABLE cam_caminhao IS 'caminhoes';

COMMENT ON COLUMN cam_caminhao.str_chassi_pk IS 'idetificacao unica do caminhao';
COMMENT ON COLUMN cam_caminhao.str_placa IS 'placa do caminhao';
COMMENT ON COLUMN cam_caminhao.str_marca IS 'marca do caminhao';
COMMENT ON COLUMN cam_caminhao.str_cor IS 'cor do caminhao';
COMMENT ON COLUMN cam_caminhao.str_tipo IS 'tipo do caminhao (veiculo urbano, semi-pesado, pesado)';
COMMENT ON COLUMN cam_caminhao.int_volume IS 'volume (valores decimais arredondados para cima)';
COMMENT ON COLUMN cam_caminhao.int_capacidade IS 'peso limite do caminhao';
COMMENT ON COLUMN cam_caminhao.dat_inclusao IS 'data de adesao do veiculo a frota';



CREATE TYPE CATEHABILITACAO AS ENUM ('B','C','D','E');
CREATE TABLE mot_motorista(
	str_nome					VARCHAR(30) NOT NULL,
	str_cod_pk				VARCHAR(30) NOT NULL,
	str_cpf   					VARCHAR(14) NOT NULL,
	str_num_habilitacao 			VARCHAR(30) NOT NULL,
	str_cate_habilitacao 			CATEHABILITACAO NOT NULL,
	dat_vencimento_habilitacao 	DATE NOT NULL,
	PRIMARY KEY(str_cod_pk)
);

COMMENT ON TABLE mot_motorista IS 'motoristas';

COMMENT ON COLUMN mot_motorista.str_nome IS 'Nome do motorista';
COMMENT ON COLUMN mot_motorista.str_cod_pk IS 'Codigo do motorista';
COMMENT ON COLUMN mot_motorista.str_cpf IS 'CPF do motorista';
COMMENT ON COLUMN mot_motorista.str_num_habilitacao IS 'Numero da CNH do motorista';
COMMENT ON COLUMN mot_motorista.str_cate_habilitacao IS 'categoria do motorista pela carteira (tipo B,C,D,E)';
COMMENT ON COLUMN mot_motorista.dat_vencimento_habilitacao IS 'Data de vencimento da CNH';



CREATE TYPE TIPO AS ENUM ('fisica', 'juridica');
CREATE TABLE cli_cliente(
	str_cpf_pk					VARCHAR(14) PRIMARY KEY,
	str_nome 					VARCHAR(30) NOT NULL,
	str_tipo   					TIPO	 NOT NULL
);

COMMENT ON TABLE cli_cliente IS 'clientes cadastrados';

COMMENT ON COLUMN cli_cliente.str_cpf_pk IS 'CPF do cliente';
COMMENT ON COLUMN cli_cliente.str_nome IS 'Nome do cliente';
COMMENT ON COLUMN cli_cliente.str_tipo IS 'Tipo do cliente (Fisico,Juridico)';

CREATE TABLE con_contato(
	str_cpf_pk				VARCHAR(14) NOT NULL,
	str_email_pk 			VARCHAR(30) NOT NULL,
	str_telefone_pk 		VARCHAR(14) NOT NULL,

	PRIMARY KEY (str_cpf_pk,str_email_pk ,str_telefone_pk),
	FOREIGN KEY (str_cpf_pk) REFERENCES cli_cliente(str_cpf_pk)
);

COMMENT ON TABLE con_contato IS 'contatos dos clientes';

COMMENT ON COLUMN con_contato.str_cpf_pk IS 'CPF do cliente';
COMMENT ON COLUMN con_contato.str_email_pk IS 'Email do cliente';
COMMENT ON COLUMN con_contato.str_telefone_pk IS 'Telefone do cliente';



CREATE TABLE ped_pedido(
	int_id_pk 					SERIAL PRIMARY KEY,
	flo_preco 					MONEY NULL,
	str_cpf_cliente_fk			VARCHAR(14) NOT NULL,
	str_destino 				VARCHAR(30) NOT NULL,
	dat_inclusao 				TIMESTAMP NOT NULL DEFAULT now(),
	FOREIGN KEY (str_cpf_cliente_fk) REFERENCES cli_cliente(str_cpf_pk)
);

COMMENT ON TABLE ped_pedido IS 'pedidos de clientes';

COMMENT ON COLUMN ped_pedido.int_id_pk IS 'Serial do pedido';
COMMENT ON COLUMN ped_pedido.flo_preco IS 'Preco do pedido';
COMMENT ON COLUMN ped_pedido.str_cpf_cliente_fk IS 'cpf do cliente';
COMMENT ON COLUMN ped_pedido.str_destino IS 'local de destino do pedido';
COMMENT ON COLUMN ped_pedido.dat_inclusao IS 'data de registro do pedido';




CREATE TABLE car_carga(
	int_id_pk				SERIAL PRIMARY KEY,
	int_idpedido_fk			INTEGER NOT NULL,
	str_chassi_vec_fk		VARCHAR(17) NULL,
	str_localizacao 			VARCHAR(30) NULL,	
	str_descricao 			TEXT NOT NULL,
	int_peso           	  		INTEGER NOT NULL,
	int_volume          	          INTEGER NOT NULL,
	dat_inclusao 		TIMESTAMP NOT NULL DEFAULT now(),

FOREIGN KEY (int_idpedido_fk) REFERENCES  ped_pedido(int_id_pk),
FOREIGN KEY (str_chassi_vec_fk) REFERENCES cam_caminhao(str_chassi_pk)
);

COMMENT ON TABLE car_carga IS 'cargas a serem tranportadas';

COMMENT ON COLUMN car_carga.int_id_pk IS 'Serial da carga';
COMMENT ON COLUMN car_carga.int_idpedido_fk IS 'Serial do pedido';
COMMENT ON COLUMN car_carga.str_chassi_vec_fk IS 'chassi do veiculo';
COMMENT ON COLUMN car_carga.str_localizacao IS 'local atual da carga';
COMMENT ON COLUMN car_carga.str_descricao IS 'descricao da carga';
COMMENT ON COLUMN car_carga.int_peso IS 'peso da carga';
COMMENT ON COLUMN car_carga.int_volume IS 'volume da carga';
COMMENT ON COLUMN car_carga.dat_inclusao IS 'data de registro da carga';


CREATE TABLE end_endereco(
	str_cpf_pk 		VARCHAR(14) NOT NULL,
	str_cep_pk 	VARCHAR(8) NOT NULL,
	int_numero_pk 	INTEGER  NOT NULL,
	str_complemento TEXT     NULL,
	PRIMARY KEY (str_cpf_pk ,str_cep_pk,int_numero_pk ),
	FOREIGN KEY (str_cpf_pk) REFERENCES cli_cliente(str_cpf_pk)
);

COMMENT ON TABLE end_endereco IS 'enderecos dos clientes';

COMMENT ON COLUMN end_endereco.str_cpf_pk IS 'CPF do cliente';
COMMENT ON COLUMN end_endereco.str_cep_pk IS 'CEP do endereco';
COMMENT ON COLUMN end_endereco.int_numero_pk IS 'numero do endereco';
COMMENT ON COLUMN end_endereco.str_complemento IS 'informacoes adicionais sobre o endereco (bloco, apartamento, etc.)';

CREATE TABLE via_viagem ( 
	int_id_pk 			SERIAL PRIMARY KEY,
	int_idrota_fk		INTEGER NOT NULL,
	str_codMotE_fk 		VARCHAR(30) NULL,
	str_codMotS_fk 		VARCHAR(30) NOT NULL,
	dat_data_partida 	TIMESTAMP NOT NULL DEFAULT now(),
	dat_data_chegada 	DATE NULL,
	str_chassi_vec_fk 	VARCHAR(17) NOT NULL,
	
	FOREIGN KEY ( int_idrota_fk ) REFERENCES rot_rota(int_id_pk ),
	FOREIGN KEY ( str_codMotE_fk ) REFERENCES mot_motorista(str_cod_pk),
	FOREIGN KEY ( str_codMotS_fk) REFERENCES mot_motorista(str_cod_pk),
	FOREIGN KEY ( str_chassi_vec_fk ) REFERENCES cam_caminhao(str_chassi_pk)  
);

ALTER TABLE via_viagem
	ADD CONSTRAINT data_diferente
		CHECK(dat_data_chegada > dat_data_partida);
ALTER TABLE via_viagem
	ADD CONSTRAINT motorista_diferente
		CHECK(str_codMotS_fk != str_codMotE_fk);
		
COMMENT ON TABLE via_viagem IS 'estrutura da viagem';

COMMENT ON COLUMN via_viagem.int_id_pk			IS 'Serial da viagem';
COMMENT ON COLUMN via_viagem.int_idrota_fk 		IS 'Rota principal a ser utilizada na viagem';
COMMENT ON COLUMN via_viagem.str_codMotE_fk 	IS 'Motorista de entrada na cidade';
COMMENT ON COLUMN via_viagem.str_codMotS_fk 	IS 'Motorista de saída da cidade';
COMMENT ON COLUMN via_viagem.dat_data_partida  	IS 'Data de partida do caminhão';
COMMENT ON COLUMN via_viagem.dat_data_chegada  IS 'Data estimada de chegada do caminhão';
COMMENT ON COLUMN via_viagem.str_chassi_vec_fk 	IS 'Chassi do caminhao a ser utilizado';

/*Funções e Gatilhos */ 
CREATE FUNCTION verifica_viagem()
	RETURNS TRIGGER AS
		$BODY$
DECLARE
	aux_viagens INTEGER;
BEGIN
	SELECT Count(via.int_id_pk) INTO aux_viagens
	FROM cam_caminhao cam,via_viagem via
	WHERE NEW.str_chassi_vec_fk = cam.str_chassi_pk
	AND cam.str_chassi_pk = via.str_chassi_vec_fk;
	
	IF(aux_viagens > 0) THEN
	RAISE EXCEPTION 'Caminhão já foi designado para uma viagem';
END IF;	
RETURN NEW;	
END;
$BODY$
language plpgsql;

CREATE TRIGGER verifica_viagem
BEFORE INSERT OR UPDATE		
ON car_carga
	 		FOR EACH ROW
				EXECUTE PROCEDURE verifica_viagem();

CREATE FUNCTION atualiza_capacidade_caminhao()
	RETURNS TRIGGER AS
		$BODY$
			DECLARE
				aux_capacidade	INTEGER;
				aux_volume	INTEGER;
			BEGIN

			IF (NEW.int_volume IS NOT NULL AND NEW.int_capacidade IS NOT NULL) THEN
				NEW.int_volume = NEW.int_volume - CEIL(NEW.int_volume /10);
RETURN NEW;
			END IF;

			aux_volume 	= NEW.int_volume;
			aux_capacidade = NEW.int_capacidade;

			IF ( NEW.str_tipo = 'VUC' ) THEN
				NEW.int_capacidade = 3000;
				NEW.int_volume = 48;
			ELSIF ( NEW.str_tipo = 'SEMP' ) THEN
				NEW.int_capacidade = 6000;
				NEW.int_volume = 120;
			ELSIF ( NEW.str_tipo = 'P' ) THEN
				NEW.int_capacidade = 12000;
				NEW.int_volume = 160;
			END IF;

			IF (aux_volume IS NOT NULL) THEN
				NEW.int_volume = aux_volume;
			END IF;
			IF (aux_capacidade IS NOT NULL) THEN
				NEW.int_capacidade = aux_capacidade;
			END IF;

			NEW.int_volume = NEW.int_volume - CEIL(NEW.int_volume /10);	
			RETURN NEW;
			END;
		$BODY$
language plpgsql;



CREATE TRIGGER atualiza_capacidade
	BEFORE INSERT OR UPDATE
		ON cam_caminhao
			FOR EACH ROW
				EXECUTE PROCEDURE atualiza_capacidade_caminhao();

/* Atualiza o peso e capacidade restantes no caminhão de acordo com a car_carga */
/*DROP FUNCTION atualiza_espaco_caminhao(capacidade integer,volume integer, chassi VARCHAR(17)) CASCADE;*/

CREATE FUNCTION atualiza_espaco_caminhao(capacidade integer,volume integer, chassi VARCHAR(17))
	RETURNS VOID AS
		$BODY$
			DECLARE
				aux_capacidade		INTEGER;
				aux_volume		INTEGER;	
			BEGIN
				SELECT cam.int_capacidade, cam.int_volume INTO aux_capacidade, aux_volume
				FROM cam_caminhao cam
				WHERE cam.str_chassi_pk = chassi;
				
				aux_capacidade = aux_capacidade - capacidade;
				aux_volume  = aux_volume - volume;
				
				UPDATE cam_caminhao SET int_capacidade = aux_capacidade, int_volume = aux_volume WHERE str_chassi_pk = chassi; 
			END;
		$BODY$
	LANGUAGE plpgsql;

/* Trigger da car_carga após a seleção de uma car_carga */
/*DROP FUNCTION verifica_carga() CASCADE;*/
CREATE FUNCTION verifica_carga()
	RETURNS trigger AS
		$BODY$
			DECLARE
				aux_capacidade	INTEGER;
				aux_volume	INTEGER;
			BEGIN
				SELECT cam.int_capacidade, cam.int_volume INTO aux_capacidade, aux_volume
				FROM cam_caminhao cam
				WHERE cam.str_chassi_pk = NEW.str_chassi_vec_fk;
				
				IF ((NEW.int_volume <= aux_volume) AND (NEW.int_peso <= aux_capacidade)) THEN
					PERFORM atualiza_espaco_caminhao(NEW.int_peso,NEW.int_volume,NEW.str_chassi_vec_fk);
				ELSE
					NEW.str_chassi_vec_fk = CAST(NULL AS VARCHAR(17));
         
                                     END IF;
                            RETURN NEW;		
	    END;
		$BODY$
	LANGUAGE plpgsql;
	
CREATE TRIGGER verifica_carga
	BEFORE INSERT OR UPDATE
		ON car_carga
			FOR EACH ROW
				EXECUTE PROCEDURE verifica_carga();

/*DROP FUNCTION atualiza_preco() CASCADE;*/
CREATE FUNCTION atualiza_preco()
	RETURNS trigger AS
		$BODY$
			DECLARE
			aux_preco		MONEY;
			aux_pesocubado  FLOAT;
			BEGIN
				SELECT p.flo_preco INTO aux_preco
				FROM ped_pedido p
				WHERE p.int_id_pk = NEW.int_idpedido_fk;
				
				aux_pesocubado = NEW.int_volume/6000;
				IF(aux_pesocubado>NEW.int_peso) THEN
					aux_preco = CAST(aux_pesocubado *3.4 AS MONEY)+ aux_preco;
				ELSE
					aux_preco = CAST(NEW.int_peso*3.4 AS MONEY) + aux_preco;
				END IF;
				UPDATE ped_pedido SET flo_preco = aux_preco WHERE int_id_pk = NEW.int_idpedido_fk;
				RETURN NEW;
			END;
		$BODY$
	LANGUAGE plpgsql;
	
CREATE TRIGGER atualiza_preco
	AFTER INSERT OR UPDATE
		ON car_carga
			FOR EACH ROW
				EXECUTE PROCEDURE atualiza_preco();


/*DROP FUNCTION verifica_habilitacao()CASCADE;*/
CREATE FUNCTION verifica_habilitacao()
	RETURNS trigger AS
    	$BODY$
        	DECLARE
        	aux_tipo     	VARCHAR(30);
        	aux_habilitacao1 CHARACTER(1);
        	aux_habilitacao2 CHARACTER(1);
        	aux_vencimento1 DATE;
aux_vencimento2 DATE;
       	 
        	BEGIN
        	SELECT cam.str_tipo INTO aux_tipo
        	FROM cam_caminhao cam
        	WHERE cam.str_chassi_pk = NEW.str_chassi_vec_fk;
                        	aux_tipo = CAST ( aux_tipo AS VARCHAR(30));

SELECT mot.str_cate_habilitacao,dat_vencimento_habilitacao INTO aux_habilitacao1,aux_vencimento1
        	FROM  mot_motorista mot
        	WHERE mot.str_cod_pk = NEW.str_codmote_fk;

aux_habilitacao1 = CAST( aux_habilitacao1 AS CHARACTER);

SELECT mot.str_cate_habilitacao,dat_vencimento_habilitacao INTO aux_habilitacao2,aux_vencimento2
        	FROM  mot_motorista mot
        	WHERE mot.str_cod_pk = NEW.str_codmots_fk;

aux_habilitacao2 = CAST( aux_habilitacao2 AS CHARACTER);

        	IF(((aux_tipo != 'VUC') AND (aux_habilitacao1 = 'B'))
OR((aux_tipo != 'VUC') AND (aux_habilitacao2 ='B'))) THEN
RAISE EXCEPTION 'Existe um mot_motorista não apto para realizar esta via_viagem.';
        	END IF;
IF((aux_vencimento1< NOW()) OR (aux_vencimento2<NOW()))THEN
RAISE EXCEPTION 'Existe um mot_motorista com habilitação vencida';
END IF;
        	RETURN NEW;
        	END;
    	$BODY$
	LANGUAGE plpgsql;
    
CREATE TRIGGER verifica_habilitacao
	BEFORE INSERT OR UPDATE
    	ON via_viagem
            	FOR EACH ROW
            	EXECUTE PROCEDURE verifica_habilitacao();



/*DROP FUNCTION atualiza_espaco_caminhao2() CASCADE;*/
CREATE FUNCTION atualiza_espaco_caminhao2()
	RETURNS trigger AS
		$BODY$
			DECLARE
				aux_capacidade		INTEGER;
				aux_volume		INTEGER;
				
			BEGIN
SELECT cam.int_capacidade, cam.int_volume       INTO aux_capacidade, aux_volume
				FROM cam_caminhao cam
WHERE cam.str_chassi_pk =    OLD.str_chassi_vec_fk;
				
				aux_capacidade = aux_capacidade + OLD.int_peso;
				aux_volume  = aux_volume +OLD.int_volume  ;
				
				UPDATE cam_caminhao SET int_capacidade = aux_capacidade, int_volume = aux_volume WHERE str_chassi_pk = OLD.str_chassi_vec_fk;
RETURN NEW;
			END;
		$BODY$
	LANGUAGE plpgsql;

CREATE TRIGGER atualiza_espaco_caminhao2
       AFTER DELETE
             ON car_carga
                FOR EACH ROW
                   EXECUTE PROCEDURE atualiza_espaco_caminhao2();

/* DROP FUNCTION verifica_preco() CASCADE; */
CREATE FUNCTION verifica_preco()
RETURNS trigger AS
		$BODY$
			DECLARE
			BEGIN
				IF (NEW.flo_preco IS NULL) THEN
					NEW.flo_preco = CAST ( 0 AS MONEY);
END IF;	
RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER verifica_preco
       BEFORE INSERT OR UPDATE
             ON ped_pedido
                FOR EACH ROW
                   EXECUTE PROCEDURE verifica_preco();



/* DROP FUNCTION verifica_disponibilidade_caminhao() CASCADE; */
CREATE FUNCTION verifica_disponibilidade_caminhao()
RETURNS trigger AS
		$BODY$
			DECLARE
				aux_data_min	DATE;
				aux_data_max	DATE;
				aux_contador	INTEGER;
			BEGIN
				aux_data_min = NEW.dat_data_partida;
				aux_data_max = NEW.dat_data_chegada;

				SELECT COUNT(*) INTO aux_contador
				FROM via_viagem
				WHERE str_chassi_vec_fk = NEW.str_chassi_vec_fk;
				
				IF (aux_contador > 0) THEN
					RAISE EXCEPTION ' Caminhão já encarregado de outra via_viagem ';
				END IF;
				RETURN NEW;
			END;
			$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER verifica_disponibilidade_caminhao
       BEFORE INSERT OR UPDATE
             ON via_viagem
                FOR EACH ROW
EXECUTE PROCEDURE	 verifica_disponibilidade_caminhao();





/*DROP FUNCTION verifica_destino() CASCADE;*/
CREATE FUNCTION verifica_destino()
RETURNS trigger AS
		$BODY$
			DECLARE
				aux_pedidos_incorretos INTEGER;
			BEGIN
				SELECT Count(p.str_destino) INTO aux_pedidos_incorretos
				FROM cam_caminhao cam,car_carga c,ped_pedido p, rot_rota r
				WHERE cam.str_chassi_pk = NEW.str_chassi_vec_fk /* Caminhão da viagem */
				AND c.str_chassi_vec_fk = cam.str_chassi_pk		
				AND p.int_id_pk = c.int_idpedido_fk	
				AND r.int_id_pk = NEW.int_idrota_fk
				AND p.str_destino != r.str_destino			
				AND p.str_destino NOT IN(					
					SELECT rot.str_destino
					FROM sub_
subrota sub, rot_rota rot
					WHERE sub.int_id_rota_principal_pkfk = r.int_id_pk
					AND rot.int_id_pk = sub.int_id_sub_rota_pkfk
				);
				IF (aux_pedidos_incorretos > 0 ) THEN
					RAISE EXCEPTION 'Existem pedidos que não estão de acordo com a rota';
				END IF;
			RETURN NEW;
			END;
		$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER verifica_destino
       BEFORE INSERT OR UPDATE
             ON via_viagem
                FOR EACH ROW
                   EXECUTE PROCEDURE verifica_destino();





/* INSERINDO VALORES TESTE PARA As TABELA */

/* cli_cliente */
INSERT INTO cli_cliente
(str_cpf_pk, str_nome, str_tipo)
VALUES('40199027048', 'Gabriel Alves Barbosa', 'fisica');
INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo)
VALUES('36884829052', 'José Sousa Gomes', 'fisica');
INSERT INTO cli_cliente
(str_cpf_pk, str_nome, str_tipo)
VALUES('22461900027', 'Victor Barros Martins', 'fisica');
INSERT INTO cli_cliente
(str_cpf_pk, str_nome, str_tipo)
VALUES('55100607009', 'Danilo Sousa Silva', 'fisica');
INSERT INTO cli_cliente
(str_cpf_pk, str_nome, str_tipo)
VALUES('86088967021', 'Vitor Fernandes Souza', 'fisica');

INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo) VALUES('10234956023', 'Leonardo Sequeiros', 'fisica');

INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo) VALUES('16431636716', 'Marco Ribeiro', 'fisica');

INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo) VALUES('49384950931', 'Bennet Ltda.', 'juridica');

INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo) VALUES('05960948302', 'Maria Rosa', 'fisica');

INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo) VALUES('46179476878', 'Afonso Bittencourt', 'fisica');

INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo) VALUES('04950393859', 'Eduardo Motta', 'fisica');

INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo) VALUES('49586902943', 'Specter Ltda.', 'juridica');



/* ped_pedido */
INSERT INTO ped_pedido
( str_cpf_cliente_fk, str_destino)VALUES
( 40199027048, 'Goiânia');/* 1 */

INSERT INTO ped_pedido
( str_cpf_cliente_fk, str_destino)VALUES
( 36884829052, 'Belo Horizonte');/* 2 */

INSERT INTO ped_pedido
( str_cpf_cliente_fk, str_destino)VALUES
( 22461900027, 'Fortaleza');/* 3 */

INSERT INTO ped_pedido
( str_cpf_cliente_fk, str_destino)VALUES
( 55100607009, 'Belo Horizonte');/* 4 */

INSERT INTO ped_pedido
( str_cpf_cliente_fk, str_destino)VALUES
( 86088967021, 'Goiânia');/* 5 */

INSERT INTO ped_pedido
( str_cpf_cliente_fk, str_destino)VALUES
(40199027048, 'Fortaleza');/* 6 */

INSERT INTO ped_pedido
(str_cpf_cliente_fk, str_destino)VALUES
(86088967021, 'Salvador');/* 7 */

INSERT INTO ped_pedido
(str_cpf_cliente_fk, str_destino)VALUES
(55100607009, 'Belo Horizonte');/* 8 */

INSERT INTO ped_pedido
(str_cpf_cliente_fk, str_destino)VALUES
(55100607009, 'Belo Horizonte');/* 9 */

/*mot_motorista */

INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome) VALUES('X022','17984973610','60669617059','B',TO_DATE('28-02-2021','DD/MM/YYYY'),'Kauã Azevedo Carvalho');

INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome) VALUES('X023','23907309821','00861538328','B',TO_DATE('21-03-2021','DD/MM/YYYY'),'Alexandre Garcia');

INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome)VALUES('X024','17001937637','40572461050','C',TO_DATE('23-11-2022','DD/MM/YYYY'),'Carlos Goncalves Lima');

INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome) VALUES('X025','40219489710','43228073050','D',TO_DATE('11-05-2020','DD/MM/YYYY'),'Diogo Araujo Azevedo');

INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome) VALUES('X026','73210109082','00116420090','E',TO_DATE('16-02-2021','DD/MM/YYYY'),'Joao Azevedo Costa');

INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome) VALUES('X027','46529802800','05855636089','C',TO_DATE('14-09-2019','DD/MM/YYYY'),'Gustavo Dias Sousa');

INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome) VALUES('X028','32864190109','89513188138','C',TO_DATE('12-03-2019','DD/MM/YYYY'),'Eduardo Anthony Barros');


/* end_endereco */

INSERT INTO end_endereco
(str_cpf_pk,str_cep_pk,int_numero_pk)VALUES('40199027048','58073483','282');

INSERT INTO end_endereco(str_cpf_pk,str_cep_pk,int_numero_pk)VALUES('36884829052','49052410','26');

INSERT INTO end_endereco
(str_cpf_pk,str_cep_pk,int_numero_pk)VALUES('22461900027','78057005','38');
INSERT INTO end_endereco
(str_cpf_pk,str_cep_pk,int_numero_pk)VALUES('55100607009','39802210','209');

INSERT INTO end_endereco
(str_cpf_pk,str_cep_pk,int_numero_pk)VALUES('55100607009','73754838','177');

INSERT INTO end_endereco
(str_cpf_pk,str_cep_pk,int_numero_pk)VALUES('86088967021','68908435','86');

/* con_contato */
INSERT INTO con_contato
(str_cpf_pk,str_email_pk,str_telefone_pk)VALUES('40199027048','gabrielbarbosa@jourrapide.com','fisica');

INSERT INTO con_contato(str_cpf_pk,str_email_pk,str_telefone_pk)VALUES('36884829052','jose_souza12@gmail.com','fisica');

INSERT INTO con_contato
(str_cpf_pk,str_email_pk,str_telefone_pk)VALUES('22461900027','vmartins12@gmail.com','fisica');

INSERT INTO con_contato
(str_cpf_pk,str_email_pk,str_telefone_pk)VALUES('55100607009','danilosilva33@hotmail.com','fisica');

INSERT INTO con_contato
(str_cpf_pk,str_email_pk,str_telefone_pk)VALUES('86088967021','vit99@hotmail.com','fisica');

INSERT INTO con_contato
(str_cpf_pk,str_email_pk,str_telefone_pk)VALUES('55100607009','dansouza44@howtocharmlady.ru','fisica');

INSERT INTO con_contato (str_cpf_pk,str_email_pk,str_telefone_pk) VALUES('16431636716', 'pedrafilo@gmail.com',21988616299);



/* cam_caminhao */

INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo )
VALUES
('74457458368', 'MOM1492', 'Mahindra', 'Prata', 'SEMP');


INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo)
VALUES
('9BGRD08X04G117974', 'KQK6389', 'Mini', 'Azul', 'VUC');

INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo)
VALUES
('9BGD849KSJFRJKFOF', 'LOL2009', 'Toyota', 'Cinza', 'SEMP');

INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo)
VALUES
('9BGDU38E02KEIO294', 'HEY5432', 'hyundai', 'vermelho', 'P');

INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo)
VALUES('9BG394RIFOAOE9645', 'GCN2001', 'Tesla', 'Indigo', 'SEMP');

INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo)
VALUES('9BG394FURET583O10', 'IPH2007', 'Apple', 'Coral', 'VUC');

INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo)
VALUES
('9BGE394RUT59384RW', 'FMA2009', 'Tesla', 'Branco', 'P');

INSERT INTO cam_caminhao(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo)
VALUES
('9BGBEGONETHOTGLFO', 'MRK1996', 'Toyota', 'Branco', 'P');


/* car_carga */
INSERT INTO car_carga
(int_idpedido_fk, str_chassi_vec_fk, str_localizacao, str_descricao, int_peso, int_volume)
VALUES
(1, '74457458368', 'Sao Paulo', 'Camisa Nike Academy Masculina', 1, 1);
INSERT INTO car_carga
(int_idpedido_fk, str_chassi_vec_fk, str_localizacao, str_descricao, int_peso, int_volume)
VALUES
(2, '74457458368', 'Rio de Janeiro', 'Barbeador eletrico Multigroom', 1, 1);

INSERT INTO car_carga
(int_idpedido_fk, str_chassi_vec_fk, str_localizacao, str_descricao, int_peso, int_volume)
VALUES
(3, '74457458368', 'Goiânia', 'Violão Strinberg Folk Eletrico', 3, 2);

INSERT INTO car_carga
(int_idpedido_fk, str_chassi_vec_fk, str_localizacao, str_descricao, int_peso, int_volume)
VALUES
(4, '74457458368', 'Vitória', 'Conjunto de Porta Retratos Vintage', 20, 1);

INSERT INTO car_carga
(int_idpedido_fk, str_chassi_vec_fk, str_localizacao, str_descricao, int_peso, int_volume)
VALUES
(5, '74457458368', 'Porto Alegre', 'HONDA CIVIC 1.8 LXS 2007/2007', 1326, 11);

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(1, 10, 20, '74457458368', 'Sao Paulo', 'car_carga de elementos quimicos');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(2, 100, 50, '74457458368', 'Rio De Janeiro', 'Produtos cariocas');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(3, 40, 60, '74457458368', 'Goiânia', 'Produtos paulistas');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(4, 60, 33, '74457458368', 'Vitória', 'Produtos mineiros');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(5, 402, 450, '74457458368', 'Porto Alegre', 'Produtos nordestinos');/*10*/

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(5, 123, 456, '74457458368', 'Porto Alegre', 'Produtos de papelaria');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(6, 123, 456, '9BGRD08X04G117974', 'Fortaleza', 'Produtos de limpeza');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(7, 123, 456, '9BGRD08X04G117974', 'Ouro Preto', 'Produtos de limpeza');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(8, 123, 456, '9BGRD08X04G117974', 'Ouro Preto', 'Produtos de limpeza');

INSERT INTO car_carga(int_idpedido_fk, int_peso, int_volume, str_chassi_vec_fk, str_localizacao, str_descricao)
VALUES
(9, 123, 456, '9BGBEGONETHOTGLFO', 'Ouro Preto', 'Produtos de limpeza');

/* rot_rota */
INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Rio de Janeiro', 'Belo Horizonte');/* 1 */

INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Campo Grande', 'Goiânia');/* 2 */

INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Salvador', 'Fortaleza');/* 3 */

INSERT INTO rot_rota
(str_origem, str_destino)VALUES('João Pessoa', 'Palmas');/* 4 */

INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Curitiba', 'Porto Alegre');/* 5 */

INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Belo Horizonte', 'Salvador');/* 6 */

INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Belo Horizonte', 'Salvador');/* 7 */

INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Rio de Janeiro', 'Fortaleza');/* 8 */

/* sub_subrota */
INSERT INTO sub_subrota(int_id_rota_principal_pkfk, int_id_sub_rota_pkfk)
VALUES
(8, 1);

INSERT INTO sub_subrota(int_id_rota_principal_pkfk, int_id_sub_rota_pkfk)
VALUES
(8, 7);

INSERT INTO sub_subrota(int_id_rota_principal_pkfk, int_id_sub_rota_pkfk)
VALUES
(8, 3);

/* via_viagem */
INSERT INTO via_viagem
(int_idrota_fk, str_codMotE_fk,str_codMotS_fk, dat_data_chegada, str_chassi_vec_fk)
VALUES
(8, 'X026', 'X025', TO_DATE('10/07/2019', 'DD/MM/YYYY'), '9BGRD08X04G117974');


INSERT INTO via_viagem
(int_idrota_fk, str_codmote_fk,str_codMotS_fk, dat_data_chegada, str_chassi_vec_fk)
VALUES
(1, 'X027', 'X024', TO_DATE('10/07/2020', 'DD/MM/YYYY'), '9BGBEGONETHOTGLFO');




/* ERROS PROPOSITAIS */

/* Volume >= 0 */
INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo,int_volume,int_capacidade)
VALUES
('9BG394FURET583O10', 'IPH2007', 'Apple', 'Coral', 'VUC',-2,2000);

/* Capacidade >= 0 */
INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo,int_volume,int_capacidade)
VALUES
('9BG394FURET583O10', 'IPH2007', 'Apple', 'Coral', 'VUC',2000,-2);

/* Origem != Destino */
INSERT INTO rot_rota
(str_origem, str_destino)VALUES('Rio de Janeiro', 'Rio de Janeiro');

/* Data de chegada > Data de partida */
INSERT INTO via_viagem
(int_idrota_fk, str_codmote_fk,str_codMotS_fk,dat_data_partida, dat_data_chegada, str_chassi_vec_fk)
VALUES
(1, 'X027', 'X024',to_date('23/12/2019', 'DD/MM/YYYY') ,to_date('22/12/2019', 'DD/MM/YYYY') , '9BGDU38E02KEIO294');

/* str_codmote_fk não pode ser igual a str_codMotS_fk */
INSERT INTO via_viagem
(int_idrota_fk, str_codmote_fk,str_codMotS_fk, dat_data_chegada, str_chassi_vec_fk)
VALUES
(1, 'X027', 'X027', to_date('23/12/2019', 'DD/MM/YYYY') , '9BGDU38E02KEIO294');

/* Caminhão deveria passar pelo destino de todos os pedidos */
INSERT INTO via_viagem
(int_idrota_fk, str_codmote_fk,str_codMotS_fk, dat_data_chegada, str_chassi_vec_fk)
VALUES
(1, 'X027', 'X024', to_date('23/12/2019', 'DD/MM/YYYY') , '74457458368');

/* str_cate_habilitacao deveria ser (B,C,D OU E) */
INSERT INTO mot_motorista (str_cod_pk,str_cpf,str_num_habilitacao,str_cate_habilitacao,dat_vencimento_habilitacao,str_nome)
VALUES
('X026','73210109082','00116420090','A',TO_DATE('16-02-2021','DD/MM/YYYY'),'Joao Azevedo Costa');

/* str_tipo deveria ser juridica ou fisica */
INSERT INTO cli_cliente(str_cpf_pk, str_nome, str_tipo)
 VALUES
 ('04950393859', 'Fulano', 'Bertrano');

/* str_tipo deveria ser ( VUC,SEMP,P) */
INSERT INTO cam_caminhao
(str_chassi_pk, str_placa, str_marca, str_cor, str_tipo )
VALUES
('74457458308', 'MOM1492', 'Mahindra', 'Prata', 'PESADO');



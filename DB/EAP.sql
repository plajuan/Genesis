CREATE TABLE contrato (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT
);

CREATE TABLE entregavel_macro (
    id SERIAL PRIMARY KEY,
    contrato_id INT NOT NULL,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT,
    FOREIGN KEY (contrato_id) REFERENCES contrato(id) ON DELETE CASCADE
);

CREATE TABLE ficha_tecnica (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao TEXT
);

CREATE TABLE item (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    tipo VARCHAR(50) CHECK (tipo IN ('material', 'serviço', 'horas_maquinario')),
    unidade VARCHAR(50),
    custo DECIMAL(10,2),
    ficha_tecnica_id INT,
    FOREIGN KEY (ficha_tecnica_id) REFERENCES ficha_tecnica(id) ON DELETE SET NULL
);

CREATE TABLE composicao_material (
    id SERIAL PRIMARY KEY,
    material_pai_id INT NOT NULL,
    item_id INT NOT NULL,
    quantidade DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (material_pai_id) REFERENCES item(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
);

CREATE TABLE entregavel_item (
    id SERIAL PRIMARY KEY,
    entregavel_macro_id INT NOT NULL,
    item_id INT NOT NULL,
    quantidade DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (entregavel_macro_id) REFERENCES entregavel_macro(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item(id) ON DELETE CASCADE
);

-- Consulta para trazer os itens do EAP com a hierarquia de contrato, entregáveis e itens
SELECT 
    c.id AS contrato_id, 
    c.nome AS contrato_nome, 
    em.id AS entregavel_id, 
    em.nome AS entregavel_nome, 
    i.id AS item_id, 
    i.nome AS item_nome, 
    i.tipo, 
    ei.quantidade
FROM contrato c
JOIN entregavel_macro em ON c.id = em.contrato_id
JOIN entregavel_item ei ON em.id = ei.entregavel_macro_id
JOIN item i ON ei.item_id = i.id
ORDER BY c.id, em.id, i.id;

-- Consulta para detalhar a composição dos entregáveis
SELECT 
    c.id AS contrato_id, 
    c.nome AS contrato_nome, 
    em.id AS entregavel_id, 
    em.nome AS entregavel_nome, 
    i.id AS item_id, 
    i.nome AS item_nome, 
    i.tipo, 
    ei.quantidade AS quantidade_entregavel, 
    cm.item_id AS subitem_id, 
    si.nome AS subitem_nome, 
    si.tipo AS subitem_tipo, 
    cm.quantidade AS quantidade_subitem
FROM contrato c
JOIN entregavel_macro em ON c.id = em.contrato_id
JOIN entregavel_item ei ON em.id = ei.entregavel_macro_id
JOIN item i ON ei.item_id = i.id
LEFT JOIN composicao_material cm ON i.id = cm.material_pai_id
LEFT JOIN item si ON cm.item_id = si.id
ORDER BY c.id, em.id, i.id, cm.item_id;





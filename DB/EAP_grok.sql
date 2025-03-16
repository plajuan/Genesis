-- Tabela para Contrato (Obra)
CREATE TABLE contrato (
    id_contrato SERIAL PRIMARY KEY,
    nome_obra VARCHAR(255) NOT NULL,
    data_inicio DATE,
    data_fim DATE,
    valor_total DECIMAL(15, 2)
);

-- Tabela para Entregáveis Macro
CREATE TABLE entregavel_macro (
    id_entregavel_macro SERIAL PRIMARY KEY,
    id_contrato INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    custo_previsto DECIMAL(15, 2),
    FOREIGN KEY (id_contrato) REFERENCES contrato(id_contrato) ON DELETE CASCADE
);

-- Tabela para Tipos de Itens (Materiais, Serviços, Horas de Maquinário)
CREATE TABLE tipo_item (
    id_tipo_item SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE -- Ex: 'Material', 'Serviço', 'Hora de Maquinário'
);

-- Tabela para Itens (Materiais, Serviços, Horas de Maquinário)
CREATE TABLE item (
    id_item SERIAL PRIMARY KEY,
    id_tipo_item INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    unidade_medida VARCHAR(50), -- Ex: 'un', 'm²', 'hora'
    custo_unitario DECIMAL(15, 2),
    FOREIGN KEY (id_tipo_item) REFERENCES tipo_item(id_tipo_item)
);

-- Tabela de Relação entre Entregável Macro e Itens
CREATE TABLE entregavel_item (
    id_entregavel_item SERIAL PRIMARY KEY,
    id_entregavel_macro INT NOT NULL,
    id_item INT NOT NULL,
    quantidade DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (id_entregavel_macro) REFERENCES entregavel_macro(id_entregavel_macro) ON DELETE CASCADE,
    FOREIGN KEY (id_item) REFERENCES item(id_item)
);

-- Tabela para Composição de Materiais (Materiais compostos por outros itens)
CREATE TABLE composicao_material (
    id_composicao SERIAL PRIMARY KEY,
    id_material_pai INT NOT NULL, -- Material que está sendo composto
    id_item_filho INT NOT NULL,  -- Item que compõe o material (pode ser material, serviço ou hora)
    quantidade DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (id_material_pai) REFERENCES item(id_item),
    FOREIGN KEY (id_item_filho) REFERENCES item(id_item),
    CONSTRAINT check_diferente CHECK (id_material_pai != id_item_filho) -- Evita auto-referência
);

-- Tabela para Ficha Técnica (Agrupamento de Itens)
CREATE TABLE ficha_tecnica (
    id_ficha_tecnica SERIAL PRIMARY KEY,
    id_entregavel_macro INT, -- Opcional: Vincula a um entregável macro
    id_material INT,         -- Opcional: Vincula a um material composto
    descricao VARCHAR(255) NOT NULL,
    custo_total_calculado DECIMAL(15, 2),
    FOREIGN KEY (id_entregavel_macro) REFERENCES entregavel_macro(id_entregavel_macro) ON DELETE SET NULL,
    FOREIGN KEY (id_material) REFERENCES item(id_item) ON DELETE SET NULL,
    CONSTRAINT check_vinculo CHECK (
        (id_entregavel_macro IS NOT NULL AND id_material IS NULL) OR 
        (id_entregavel_macro IS NULL AND id_material IS NOT NULL) OR 
        (id_entregavel_macro IS NULL AND id_material IS NULL)
    ) -- Garante que a ficha seja vinculada a um entregável OU material, ou nenhum
);

-- Tabela de Relação entre Ficha Técnica e Itens
CREATE TABLE ficha_tecnica_item (
    id_ficha_tecnica_item SERIAL PRIMARY KEY,
    id_ficha_tecnica INT NOT NULL,
    id_item INT NOT NULL,
    quantidade DECIMAL(15, 2) NOT NULL,
    FOREIGN KEY (id_ficha_tecnica) REFERENCES ficha_tecnica(id_ficha_tecnica) ON DELETE CASCADE,
    FOREIGN KEY (id_item) REFERENCES item(id_item)
);

-- Inserção de Tipos de Itens Básicos
INSERT INTO tipo_item (nome) VALUES 
    ('Material'),
    ('Serviço'),
    ('STC'),
    ('Equipamento');

=================

-- Consulta principal para obter a EAP completa a partir de um contrato específico
WITH RECURSIVE composicao AS (
    -- Base: Itens diretamente associados a entregáveis macro
    SELECT 
        ei.id_entregavel_macro,
        ei.id_item AS id_item_filho,
        i.descricao AS item_descricao,
        ti.nome AS tipo_item,
        ei.quantidade,
        i.custo_unitario,
        ei.quantidade * i.custo_unitario AS custo_total,
        1 AS nivel,
        i.descricao AS caminho
    FROM entregavel_item ei
    JOIN item i ON ei.id_item = i.id_item
    JOIN tipo_item ti ON i.id_tipo_item = ti.id_tipo_item

    UNION ALL

    -- Recursivo: Composição de materiais
    SELECT 
        c.id_entregavel_macro,
        cm.id_item_filho,
        i.descricao AS item_descricao,
        ti.nome AS tipo_item,
        cm.quantidade,
        i.custo_unitario,
        cm.quantidade * i.custo_unitario AS custo_total,
        c.nivel + 1 AS nivel,
        c.caminho || ' -> ' || i.descricao AS caminho
    FROM composicao c
    JOIN composicao_material cm ON c.id_item_filho = cm.id_material_pai
    JOIN item i ON cm.id_item_filho = i.id_item
    JOIN tipo_item ti ON i.id_tipo_item = ti.id_tipo_item
)

-- Consulta final para montar a EAP
SELECT 
    c.nome_obra AS contrato,
    em.descricao AS entregavel_macro,
    comp.item_descricao AS item,
    comp.tipo_item,
    comp.quantidade,
    comp.custo_unitario,
    comp.custo_total,
    comp.nivel,
    comp.caminho AS hierarquia
FROM contrato c
JOIN entregavel_macro em ON c.id_contrato = em.id_contrato
LEFT JOIN composicao comp ON em.id_entregavel_macro = comp.id_entregavel_macro
WHERE c.id_contrato = 1 -- Substitua pelo ID do contrato desejado
ORDER BY 
    em.descricao, 
    comp.nivel, 
    comp.caminho;

==========

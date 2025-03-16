-- Tabela: Projeto
CREATE TABLE projeto (
    id_projeto SERIAL PRIMARY KEY,
    nome_projeto VARCHAR(255) NOT NULL,
    data_inicio DATE,
    data_fim_prevista DATE,
    descricao TEXT
);

-- Tabela: Centro de Custo
CREATE TABLE centro_custo (
    id_centro_custo SERIAL PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    codigo VARCHAR(50) UNIQUE -- Ex.: "FUN" para Fundação, "EST" para Estrutura
);

-- Tabela: Custo por Unidade (CPU)
CREATE TABLE custo_unidade (
    id_custo_unidade SERIAL PRIMARY KEY,
    codigo INT NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    unidade_medida VARCHAR(50), -- Ex.: m², m³, hora
    valor_total DECIMAL(15, 2) NOT NULL CHECK (valor_total >= 0)
);

-- Tabela: Orçamento Aprovado (liga Projeto, Centro de Custo e Custo por Unidade)
CREATE TABLE orcamento_aprovado (
    id_orcamento SERIAL PRIMARY KEY,
    id_projeto INT NOT NULL,
    id_centro_custo INT NOT NULL,
    id_custo_unidade INT NOT NULL,
    valor_total_aprovado DECIMAL(15, 2) NOT NULL CHECK (valor_total_aprovado >= 0),
    data_aprovacao DATE NOT NULL,    
    descricao VARCHAR(255),
    FOREIGN KEY (id_projeto) REFERENCES projeto(id_projeto) ON DELETE CASCADE,
    FOREIGN KEY (id_centro_custo) REFERENCES centro_custo(id_centro_custo) ON DELETE RESTRICT,
    FOREIGN KEY (id_custo_unidade) REFERENCES custo_unidade(id_custo_unidade) ON DELETE RESTRICT
);

-- Tabela: Item
CREATE TABLE item (
    id_item SERIAL PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    tipo_item VARCHAR(50) NOT NULL CHECK (tipo_item IN ('Material', 'Serviço', 'Equipamento', 'Terceirizado')),
    unidade_medida VARCHAR(50),
    valor_unitario DECIMAL(15, 2) NOT NULL CHECK (quantidade >= 0)
);

-- Tabela: Composição do Item (duas ligações com Item: pai e filho)
CREATE TABLE composicao_item (
    id_composicao SERIAL PRIMARY KEY,
    id_item_pai INT NOT NULL,
    id_item_filho INT NOT NULL,
    quantidade DECIMAL(15, 2) NOT NULL CHECK (quantidade >= 0),
    FOREIGN KEY (id_item_pai) REFERENCES item(id_item) ON DELETE CASCADE,
    FOREIGN KEY (id_item_filho) REFERENCES item(id_item) ON DELETE RESTRICT,
    CONSTRAINT check_diferente CHECK (id_item_pai != id_item_filho)
);

-- Tabela: CPU_Item (liga Custo por Unidade e Item)
CREATE TABLE cpu_item (
    id_cpu_item SERIAL PRIMARY KEY,
    id_custo_unidade INT NOT NULL,
    id_item INT NOT NULL,
    quantidade_prevista DECIMAL(15, 2) NOT NULL CHECK (quantidade_prevista >= 0),
    FOREIGN KEY (id_custo_unidade) REFERENCES custo_unidade(id_custo_unidade) ON DELETE CASCADE,
    FOREIGN KEY (id_item) REFERENCES item(id_item) ON DELETE RESTRICT
);

-- Tabela: Orçamento_Item (liga Orçamento Aprovado e Item)
CREATE TABLE orcamento_item (
    id_orcamento_item SERIAL PRIMARY KEY,
    id_orcamento INT NOT NULL,
    id_item INT NOT NULL,
    quantidade_orcada DECIMAL(15, 2) NOT NULL CHECK (quantidade_orcada >= 0),
    valor_orcado DECIMAL(15, 2) NOT NULL CHECK (valor_orcado >= 0),
    FOREIGN KEY (id_orcamento) REFERENCES orcamento_aprovado(id_orcamento) ON DELETE CASCADE,
    FOREIGN KEY (id_item) REFERENCES item(id_item) ON DELETE RESTRICT
);

-- Tabela: Execução do Orçamento (liga Orçamento_Item)
CREATE TABLE execucao_orcamento (
    id_execucao SERIAL PRIMARY KEY,
    id_orcamento_item INT NOT NULL,
    data_execucao DATE NOT NULL DEFAULT CURRENT_DATE,
    quantidade_executada DECIMAL(15, 2) NOT NULL CHECK (quantidade_executada >= 0),
    valor_executado DECIMAL(15, 2) NOT NULL CHECK (valor_executado >= 0),    
    descricao VARCHAR(255),
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_orcamento_item) REFERENCES orcamento_item(id_orcamento_item) ON DELETE RESTRICT
);

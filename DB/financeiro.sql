-- Create schema
CREATE SCHEMA IF NOT EXISTS djangosige;
SET search_path TO djangosige;

-- Base App Tables
CREATE TABLE empresa (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    inscricao_estadual VARCHAR(20),
    endereco_logradouro VARCHAR(255),
    endereco_numero VARCHAR(10),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100),
    endereco_estado VARCHAR(2),
    endereco_cep VARCHAR(9),
    telefone VARCHAR(15),
    email VARCHAR(255)
);

CREATE TABLE cliente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cpf_cnpj VARCHAR(18) UNIQUE NOT NULL,
    tipo_pessoa CHAR(1),
    endereco_logradouro VARCHAR(255),
    endereco_numero VARCHAR(10),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100),
    endereco_estado VARCHAR(2),
    endereco_cep VARCHAR(9),
    telefone VARCHAR(15),
    email VARCHAR(255),
    limite_credito NUMERIC(10, 2) DEFAULT 0.00
);

CREATE TABLE banco (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL
);

-- Cadastro App Tables
CREATE TABLE fornecedor (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    inscricao_estadual VARCHAR(20),
    endereco_logradouro VARCHAR(255),
    endereco_numero VARCHAR(10),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100),
    endereco_estado VARCHAR(2),
    endereco_cep VARCHAR(9),
    telefone VARCHAR(15),
    email VARCHAR(255)
);

CREATE TABLE transportadora (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    endereco_logradouro VARCHAR(255),
    endereco_numero VARCHAR(10),
    endereco_bairro VARCHAR(100),
    endereco_cidade VARCHAR(100),
    endereco_estado VARCHAR(2),
    endereco_cep VARCHAR(9)
);

-- Estoque App Tables
CREATE TABLE produto (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    unidade VARCHAR(10),
    preco_venda NUMERIC(10, 2) NOT NULL,
    estoque_atual INTEGER DEFAULT 0,
    estoque_minimo INTEGER DEFAULT 0
);

CREATE TABLE local_estoque (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL
);

CREATE TABLE movimento_estoque (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER REFERENCES produto(id) ON DELETE CASCADE,
    local_estoque_id INTEGER REFERENCES local_estoque(id) ON DELETE SET NULL,
    quantidade INTEGER NOT NULL,
    data_movimento DATE NOT NULL,
    tipo_movimento CHAR(1)
);

-- Vendas App Tables
CREATE TABLE condicao_pagamento (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(100) NOT NULL,
    numero_parcelas INTEGER DEFAULT 1,
    dias_entre_parcelas INTEGER DEFAULT 30
);

CREATE TABLE venda (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER REFERENCES cliente(id) ON DELETE SET NULL,
    data_emissao DATE NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Aberta',
    condicao_pagamento_id INTEGER REFERENCES condicao_pagamento(id) ON DELETE SET NULL,
    transportadora_id INTEGER REFERENCES transportadora(id) ON DELETE SET NULL
);

CREATE TABLE item_venda (
    id SERIAL PRIMARY KEY,
    venda_id INTEGER REFERENCES venda(id) ON DELETE CASCADE,
    produto_id INTEGER REFERENCES produto(id) ON DELETE CASCADE,
    quantidade INTEGER NOT NULL,
    valor_unitario NUMERIC(10, 2) NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL
);

-- Compras App Tables
CREATE TABLE compra (
    id SERIAL PRIMARY KEY,
    fornecedor_id INTEGER REFERENCES fornecedor(id) ON DELETE SET NULL,
    data_emissao DATE NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Aberta'
);

CREATE TABLE item_compra (
    id SERIAL PRIMARY KEY,
    compra_id INTEGER REFERENCES compra(id) ON DELETE CASCADE,
    produto_id INTEGER REFERENCES produto(id) ON DELETE CASCADE,
    quantidade INTEGER NOT NULL,
    valor_unitario NUMERIC(10, 2) NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL
);

-- Financeiro App Tables
CREATE TABLE conta_pagar (
    id SERIAL PRIMARY KEY,
    compra_id INTEGER REFERENCES compra(id) ON DELETE SET NULL,
    valor NUMERIC(10, 2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    pago BOOLEAN DEFAULT FALSE
);

CREATE TABLE conta_receber (
    id SERIAL PRIMARY KEY,
    venda_id INTEGER REFERENCES venda(id) ON DELETE SET NULL,
    valor NUMERIC(10, 2) NOT NULL,
    data_vencimento DATE NOT NULL,
    data_recebimento DATE,
    recebido BOOLEAN DEFAULT FALSE
);

CREATE TABLE lancamento (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    valor NUMERIC(10, 2) NOT NULL,
    data_lancamento DATE NOT NULL,
    tipo_lancamento CHAR(1),
    conta_pagar_id INTEGER REFERENCES conta_pagar(id) ON DELETE SET NULL,
    conta_receber_id INTEGER REFERENCES conta_receber(id) ON DELETE SET NULL
);

-- Fiscal App Tables (Adicionadas)
CREATE TABLE natureza_operacao (
    id SERIAL PRIMARY KEY,
    descricao VARCHAR(255) NOT NULL,
    cfop VARCHAR(10) NOT NULL,
    tipo_operacao CHAR(1) NOT NULL,
    observacao TEXT
);

CREATE TABLE tributos (
    id SERIAL PRIMARY KEY,
    produto_id INTEGER REFERENCES produto(id) ON DELETE CASCADE,
    cst_icms VARCHAR(3),
    cst_pis VARCHAR(2),
    cst_cofins VARCHAR(2),
    aliquota_icms NUMERIC(5, 2),
    aliquota_pis NUMERIC(5, 2),
    aliquota_cofins NUMERIC(5, 2),
    valor_bc_icms NUMERIC(10, 2),
    valor_bc_pis NUMERIC(10, 2),
    valor_bc_cofins NUMERIC(10, 2)
);

CREATE TABLE nota_fiscal (
    id SERIAL PRIMARY KEY,
    tipo CHAR(1) NOT NULL,
    serie VARCHAR(3) NOT NULL,
    numero VARCHAR(9) UNIQUE NOT NULL,
    data_emissao DATE NOT NULL,
    valor_total NUMERIC(10, 2) NOT NULL,
    cliente_id INTEGER REFERENCES cliente(id) ON DELETE SET NULL,
    fornecedor_id INTEGER REFERENCES fornecedor(id) ON DELETE SET NULL,
    venda_id INTEGER REFERENCES venda(id) ON DELETE SET NULL,
    compra_id INTEGER REFERENCES compra(id) ON DELETE SET NULL,
    natureza_operacao_id INTEGER REFERENCES natureza_operacao(id) ON DELETE SET NULL,
    transportadora_id INTEGER REFERENCES transportadora(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'Pendente',
    chave_nfe VARCHAR(44) UNIQUE,
    xml_nfe TEXT,
    observacao TEXT
);

-- Índices
CREATE INDEX idx_venda_cliente ON venda(cliente_id);
CREATE INDEX idx_compra_fornecedor ON compra(fornecedor_id);
CREATE INDEX idx_item_venda_venda ON item_venda(venda_id);
CREATE INDEX idx_item_compra_compra ON item_compra(compra_id);
CREATE INDEX idx_nota_fiscal_venda ON nota_fiscal(venda_id);
CREATE INDEX idx_nota_fiscal_compra ON nota_fiscal(compra_id);
CREATE INDEX idx_nota_fiscal_cliente ON nota_fiscal(cliente_id);
CREATE INDEX idx_tributos_produto ON tributos(produto_id);

-- Criar schema (opcional)
CREATE SCHEMA IF NOT EXISTS erpnext;
SET search_path TO erpnext;

-- Tabelas Base do Frappe Framework
CREATE TABLE tabDocType (
    name VARCHAR(255) PRIMARY KEY,
    module VARCHAR(255) NOT NULL,
    creation TIMESTAMP,
    modified TIMESTAMP,
    owner VARCHAR(255),
    docstatus INTEGER DEFAULT 0, -- 0: Draft, 1: Submitted, 2: Cancelled
    description TEXT
);

CREATE TABLE tabSingles (
    doctype VARCHAR(255) NOT NULL,
    field VARCHAR(255) NOT NULL,
    value TEXT,
    PRIMARY KEY (doctype, field)
);

CREATE TABLE tabUser (
    name VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    creation TIMESTAMP,
    modified TIMESTAMP,
    enabled BOOLEAN DEFAULT TRUE
);

-- Módulo Contabilidade
CREATE TABLE tabAccount (
    name VARCHAR(255) PRIMARY KEY,
    account_name VARCHAR(255) NOT NULL,
    parent_account VARCHAR(255) REFERENCES tabAccount(name) ON DELETE SET NULL,
    account_type VARCHAR(50),
    balance NUMERIC(15, 6) DEFAULT 0.00,
    creation TIMESTAMP,
    modified TIMESTAMP,
    owner VARCHAR(255),
    docstatus INTEGER DEFAULT 0
);

CREATE TABLE tabGL_Entry (
    name VARCHAR(255) PRIMARY KEY,
    posting_date DATE NOT NULL,
    account VARCHAR(255) REFERENCES tabAccount(name) ON DELETE CASCADE,
    debit NUMERIC(15, 6) DEFAULT 0.00,
    credit NUMERIC(15, 6) DEFAULT 0.00,
    voucher_type VARCHAR(50),
    voucher_no VARCHAR(255),
    creation TIMESTAMP,
    modified TIMESTAMP,
    docstatus INTEGER DEFAULT 0
);

-- Módulo Estoque
CREATE TABLE tabItem (
    name VARCHAR(255) PRIMARY KEY,
    item_code VARCHAR(255) UNIQUE NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    item_group VARCHAR(255),
    stock_uom VARCHAR(50),
    valuation_rate NUMERIC(15, 6) DEFAULT 0.00,
    creation TIMESTAMP,
    modified TIMESTAMP,
    owner VARCHAR(255),
    docstatus INTEGER DEFAULT 0
);

CREATE TABLE tabStock_Entry (
    name VARCHAR(255) PRIMARY KEY,
    posting_date DATE NOT NULL,
    purpose VARCHAR(50), -- Material Issue, Receipt, Transfer, etc.
    total_amount NUMERIC(15, 6) DEFAULT 0.00,
    creation TIMESTAMP,
    modified TIMESTAMP,
    owner VARCHAR(255),
    docstatus INTEGER DEFAULT 0
);

CREATE TABLE tabStock_Entry_Detail (
    name VARCHAR(255) PRIMARY KEY,
    parent VARCHAR(255) REFERENCES tabStock_Entry(name) ON DELETE CASCADE,
    item_code VARCHAR(255) REFERENCES tabItem(name) ON DELETE CASCADE,
    qty NUMERIC(15, 6) NOT NULL,
    basic_rate NUMERIC(15, 6) DEFAULT 0.00
);

-- Módulo Vendas
CREATE TABLE tabCustomer (
    name VARCHAR(255) PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    customer_group VARCHAR(255),
    territory VARCHAR(255),
    creation TIMESTAMP,
    modified TIMESTAMP,
    owner VARCHAR(255),
    docstatus INTEGER DEFAULT 0
);

CREATE TABLE tabSales_Invoice (
    name VARCHAR(255) PRIMARY KEY,
    customer VARCHAR(255) REFERENCES tabCustomer(name) ON DELETE SET NULL,
    posting_date DATE NOT NULL,
    grand_total NUMERIC(15, 6) NOT NULL,
    outstanding_amount NUMERIC(15, 6) DEFAULT 0.00,
    creation TIMESTAMP,
    modified TIMESTAMP,
    owner VARCHAR(255),
    docstatus INTEGER DEFAULT 0
);

CREATE TABLE tabSales_Invoice_Item (
    name VARCHAR(255) PRIMARY KEY,
    parent VARCHAR(255) REFERENCES tabSales_Invoice(name) ON DELETE CASCADE,
    item_code VARCHAR(255) REFERENCES tabItem(name) ON DELETE CASCADE,
    qty NUMERIC(15, 6) NOT NULL,
    rate NUMERIC(15, 6) NOT NULL,
    amount NUMERIC(15, 6) NOT NULL
);

-- Índices
CREATE INDEX idx_gl_entry_account ON tabGL_Entry(account);
CREATE INDEX idx_stock_entry_detail_parent ON tabStock_Entry_Detail(parent);
CREATE INDEX idx_sales_invoice_customer ON tabSales_Invoice(customer);


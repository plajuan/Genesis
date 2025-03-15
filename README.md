# Genesis
Ideias para a organização do banco de dados para um projeto EAP

## Rascunho
Contrato: Armazena informações básicas da obra.
    Entregavel_Macro: Cada obra tem vários entregáveis macro, ligados ao contrato via chave estrangeira.
    Item: Tabela central que define os itens (materiais, serviços ou horas de maquinário). O campo tipo_item diferencia os tipos.
    Material, Servico, Hora_Maquinario: Tabelas específicas para cada tipo de item, com atributos próprios (ex.: custo unitário para materiais, horas previstas para serviços).
    Composicao_Item: Permite que um material seja composto por outros itens (materiais, serviços ou horas de maquinário), criando uma estrutura hierárquica.

Ficha Técnica (Exemplo de Consulta SQL)

A ficha técnica mostra a composição de um item específico, incluindo todos os subitens que o compõem.
sql
-- Consulta para gerar a ficha técnica de um item específico (ex.: id_item = 1)
SELECT 
    i.nome_item AS 'Nome do Item Principal',
    i.unidade_medida AS 'Unidade Medida',
    i.quantidade AS 'Quantidade Principal',
    ci.quantidade AS 'Quantidade Composição',
    ifil.nome_item AS 'Nome do Subitem',
    ifil.unidade_medida AS 'Unidade Medida Subitem',
    ifil.tipo_item AS 'Tipo do Subitem',
    CASE 
        WHEN ifil.tipo_item = 'Material' THEN m.custo_unitario
        WHEN ifil.tipo_item = 'Servico' THEN s.custo_hora
        WHEN ifil.tipo_item = 'Hora_Maquinario' THEN hm.custo_hora
    END AS 'Custo Unitário'
FROM 
    Item i
LEFT JOIN 
    Composicao_Item ci ON i.id_item = ci.id_item_pai
LEFT JOIN 
    Item ifil ON ci.id_item_filho = ifil.id_item
LEFT JOIN 
    Material m ON ifil.id_item = m.id_item AND ifil.tipo_item = 'Material'
LEFT JOIN 
    Servico s ON ifil.id_item = s.id_item AND ifil.tipo_item = 'Servico'
LEFT JOIN 
    Hora_Maquinario hm ON ifil.id_item = hm.id_item AND ifil.tipo_item = 'Hora_Maquinario'
WHERE 
    i.id_item = 1; -- Substitua pelo ID do item desejado

Exemplo de Saída da Ficha Técnica
Nome do Item Principal	Unidade Medida	Quantidade Principal	Quantidade Composição	Nome do Subitem	Unidade Medida Subitem	Tipo do Subitem	Custo Unitário
Concreto Armado	m³	100.00	50.00	Cimento	kg	Material	0.50
Concreto Armado	m³	100.00	20.00	Areia	m³	Material	30.00
Concreto Armado	m³	100.00	10.00	Mão de Obra Concreto	hora	Servico	25.00
Concreto Armado	m³	100.00	5.00	Betoneira	hora	Hora_Maquinario	50.00

Observações

    O modelo suporta composição recursiva (um material pode ser composto por outros materiais, que por sua vez podem ter subitens).
    A consulta da ficha técnica usa LEFT JOIN para garantir que itens sem composição também sejam exibidos.
    Você pode adicionar índices ou ajustar os tipos de dados (ex.: DECIMAL) conforme as necessidades específicas do projeto.

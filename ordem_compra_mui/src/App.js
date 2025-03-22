import React, { useState, useEffect } from 'react';
import { 
  Container, Card, CardContent, Typography, TextField, MenuItem, Button, 
  Table, TableBody, TableCell, TableHead, TableRow, IconButton, Box 
} from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import Autocomplete from '@mui/material/Autocomplete';

const produtos = [
  { id: 1, nome: 'Cimento (50kg)', preco: 25.00 },
  { id: 2, nome: 'Tijolo Cerâmico', preco: 0.50 },
  { id: 3, nome: 'Areia (m³)', preco: 80.00 },
];

function App() {
  const [ordem, setOrdem] = useState({
    numero: 'OC-2025-001',
    fornecedor: 'Fornecedor A',
    dataEmissao: '2025-03-22',
  });

  const [itens, setItens] = useState([
    { id: 1, produto: produtos[0], quantidade: 10, preco: 25.00, total: 250.00 },
  ]);

  // Calcular total geral
  const calcularTotalGeral = () => {
    const total = itens.reduce((sum, item) => sum + Number(item.total), 0);
    return total.toFixed(2); // Garantir que total é um número antes de .toFixed
  };

  // Adicionar nova linha
  const adicionarItem = () => {
    const novoItem = {
      id: Date.now(),
      produto: null,
      quantidade: 1,
      preco: 0.00,
      total: 0.00,
    };
    setItens([...itens, novoItem]);
  };

  // Remover linha
  const removerItem = (id) => {
    setItens(itens.filter(item => item.id !== id));
  };

  // Atualizar item
  const atualizarItem = (id, campo, valor) => {
    const novosItens = itens.map(item => {
      if (item.id === id) {
        const updatedItem = { ...item, [campo]: valor };
        if (campo === 'produto' && valor) {
          updatedItem.preco = valor.preco;
        }
        updatedItem.total = (Number(updatedItem.quantidade) * Number(updatedItem.preco)).toFixed(2);
        return updatedItem;
      }
      return item;
    });
    setItens(novosItens);
  };

  return (
    <Container sx={{ mt: 5 }}>
      {/* Master Section */}
      <Typography variant="h4" gutterBottom>Ordem de Compras</Typography>
      <Card sx={{ mb: 4 }}>
        <CardContent>
          <Box display="flex" gap={2}>
            <TextField
              label="Número da Ordem"
              value={ordem.numero}
              InputProps={{ readOnly: true }}
              fullWidth
            />
            <TextField
              select
              label="Fornecedor"
              value={ordem.fornecedor}
              onChange={(e) => setOrdem({ ...ordem, fornecedor: e.target.value })}
              fullWidth
            >
              <MenuItem value="Fornecedor A">Fornecedor A</MenuItem>
              <MenuItem value="Fornecedor B">Fornecedor B</MenuItem>
            </TextField>
            <TextField
              type="date"
              label="Data de Emissão"
              value={ordem.dataEmissao}
              onChange={(e) => setOrdem({ ...ordem, dataEmissao: e.target.value })}
              fullWidth
              InputLabelProps={{ shrink: true }}
            />
          </Box>
        </CardContent>
      </Card>

      {/* Detail Section */}
      <Typography variant="h5" gutterBottom>Itens da Ordem</Typography>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Produto</TableCell>
            <TableCell>Quantidade</TableCell>
            <TableCell>Preço Unitário (R$)</TableCell>
            <TableCell>Total (R$)</TableCell>
            <TableCell>Ações</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {itens.map((item) => (
            <TableRow key={item.id}>
              <TableCell>
                <Autocomplete
                  options={produtos}
                  getOptionLabel={(option) => option.nome}
                  value={item.produto}
                  onChange={(e, newValue) => atualizarItem(item.id, 'produto', newValue)}
                  renderInput={(params) => (
                    <TextField {...params} placeholder="Digite para buscar produto" variant="outlined" />
                  )}
                  sx={{ width: 250 }}
                />
              </TableCell>
              <TableCell>
                <TextField
                  type="number"
                  value={item.quantidade}
                  onChange={(e) => atualizarItem(item.id, 'quantidade', parseFloat(e.target.value) || 0)}
                  inputProps={{ min: 1 }}
                  sx={{ width: 100 }}
                />
              </TableCell>
              <TableCell>
                <TextField
                  type="number"
                  value={item.preco}
                  onChange={(e) => atualizarItem(item.id, 'preco', parseFloat(e.target.value) || 0)}
                  inputProps={{ step: 0.01 }}
                  sx={{ width: 120 }}
                />
              </TableCell>
              <TableCell>{item.total}</TableCell>
              <TableCell>
                <IconButton color="error" onClick={() => removerItem(item.id)}>
                  <DeleteIcon />
                </IconButton>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>

      {/* Botão Adicionar e Total Geral */}
      <Box sx={{ mt: 2, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Button variant="contained" color="primary" onClick={adicionarItem}>
          Adicionar Item
        </Button>
        <Typography variant="h6">
          Total Geral: R$ {calcularTotalGeral()}
        </Typography>
      </Box>
    </Container>
  );
}

export default App;

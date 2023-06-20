# ![S3](../imagens/S3.png "Ícone do AWS S3") Estudos de AWS S3 - Teoria

> **Simple Storage Service (S3)**: sistema de armazenamento de objetos

- [1. Conceitos iniciais](#1-conceitos-iniciais)
- [2. Classes de Armazenamento](#2-classes-de-armazenamento)
- [3. Gerenciamento de Armazenamento](#3-gerenciamento-de-armazenamento)

    - [3.1. Política de Ciclo de Vida](#31-política-de-ciclo-de-vida)
    - [3.2. Bloqueio de Objetos](#32-bloqueio-de-objetos)
    - [3.3. Cross-Replication](#33-replicação)
    - [3.4. S3 Batch Operations](#34-s3-batch-operations)
    - [3.5. Versionamento](#35-versionamento)
- [4. Gerenciamento de acesso e segurança](#4-gerenciamento-de-acesso-e-segurança)
    - [4.1. Bloqueio de acesso público](#41-bloqueio-de-acesso-público)
    - [4.2. IAM](#42-iam)
    - [4.3. Bucket Policy](#43-bucket-policy) <<< doing
    - [4.4. Endpoints](#44-endpoints) <<< to do
    - [4.5. ACLs](#45-acls) <<< to do
    - [4.6. Propriedade de objeto do S3](#46-propriedade-de-objeto-do-s3) <<< to do
    - [4.7. IAM access analyzer para S3](#47-iam-access-analyzer-para-s3) <<< to do
- [5. Outros recursos](#5-outros-recursos)
    - [5.1. S3 Storage Lens](#51-s3-storage-lens) <<< to do
    - [5.2. Análise de classes de armazenamento](#52-análise-de-classes-de-armazenamento) <<< to do
    - [5.3. S3 Transfer Accelerator](#53-s3-transfer-accelerator) <<< to do
    - [5.4. Logs de acesso](#54-logs-de-acesso) <<< to do
    - [5.5. S3 Select](#55-s3-select) <<< to do
    - [5.6. Hospedagem de sites estáticos](#56-hospedagem-de-sites-estáticos) <<< to do
- [6. Modelo de consistência de dados](#6-modelo-de-consistência-de-dados) <<< to do

---

## 1. Conceitos iniciais

O S3 pode ser usado para armazenar qualquer volume de dados estruturados, semi-estruturados e não estruturados. O serviço garante alta durabilidade e disponibilidade dos objetos armazenados porque os dados são armazenados em pelo menos 3 zonas de disponibilidade de forma automática.

![S3](../imagens/s3-intro.png "AWS S3")

- **Buckets**: os dados são armazenados em Buckets que são estruturas com nome único em toda a internet (2 buckets não podem ter o mesmo nome em todo o planeta). Não há limites para a quantidade de dados que você pode armazenar no Bucket;

- **Objetos**: são os arquivos, dados ou qualquer item a ser armazenado nos buckets. Cada objeto possui as seguintes caracterísitcas:
    
    - Possui um **Key** que é o nome do objeto dentro do bucket;
    - Pode ter um **version ID** que representa a versão do objeto no bucket. A junção da Key com o Version ID identificam cada objeto no bucket como único;
    - **Value**, que é o conteúdo do objeto. Cada objeto individualmente pode ter até 5 TB.

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-s3-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingObjects.html)

---

## 2. Classes de Armazenamento

**S3 Standart**: Classe padrão. Se você não especificar a classe ao fazer upload de um objeto, o S3 assumirá a classe S3 Standart. Destinada para dados acessados com frequência. Você paga por GB armazenado e pelo n° de chamadas as APIs do S3 (PUT, GET, COPY, ...). Não há taxas de recuperação para S3-Standart;

**S3 Intelligent-Tiering**: Automação que movimenta os arquivos automaticamente para a classe mais apropriada. Você é cobrado pelo armazenamento, chamadas à API e pela quantidade de objetos monitorados pelo Inteligent-Tiering. Ideal quando o padrão de acesso dos objetos é desconhecido ou variável. Não há taxas de recuperação para S3 Intelligent-Tiering. Para acessar arquivos que o Intelligent-Tiering moveu para arquivamento, é preciso primeiro restaurá-los. Ao tentar acessar um objeto movido para uma classe de acesso infrequente, o Intelligent-Tiering o move primeiro para uma classe de acesso frequente para não serem cobradas taxas de recuperação.
Se o tamanho de um objeto for menor que 128 KB, ele não será monitorado nem qualificado para o nivelamento automático. Objetos menores que isso são sempre armazenados no nível de acesso frequente;

**S3 Standart – IA**: Para dados duradouros e acessados com pouca frequência. A latência do primeiro bit é de milissegundos também, mas é cobrada uma taxa por recuperação. Se um objeto tiver menos de 128 KB e for armazenado nessa classe, ele será cobrado como um objeto de 128 KB. Além disso, o tempo mínimo cobrado pelo objeto é de 30 dias. Se ele ficar salvo por 1 dia e for deletado, você é cobrado por um armazenamento de 30 dias;

**S3 One Zone – IA**: Para dados duradouros e acessados com pouca frequência que podem ser gerados novamente ou que não são críticos e que não precisam de alta resiliência e disponibilidade. Ao contrário das outras classes que utilizam um modelo de replicação do dado em pelo menos 3 AZs, essa classe usa somente uma AZ;

**S3 Glacier Instant Retrieval**: Para arquivar dados que raramente são acessados e exigem recuperação de milissegundos. A taxa de recuperação do dado é mais alta;

**S3 Glacier Flexible Retrieval**: Possui um período mínimo de armazenamento de 90 dias e a latência do primeiro bit é de 1 a 5 minutos;

**S3 Glacier Deep Archive**: Classe mais barata, para dados raramente acessados. Os dados têm um período mínimo de duração de armazenamento de 180 dias e um tempo de recuperação padrão de 12 horas.

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-storage_class-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/storage-class-intro.html)

---

## 3. Gerenciamento de Armazenamento

### 3.1. Política de Ciclo de Vida

> Te permite configurar políticas de ciclo de vida dos objetos em um Bucket. Com a regra de ciclo de vida, você consegue definir:

- **Escopo**: dizer se a regra será aplicada a todos os objetos do bucket ou a objetos que atendam a uma regra específica (com uma tag, prefixo no nome, que tenham um tamanho mínimo ou máximo);
- **Ação da versão atual**: refere-se a ação de mover a versão mais recente do objeto entre classes de armazenamento a partir da quantidade de dias de vida do objeto;
- **Ações de versões desatualizadas**: basicamente, você pode fazer a mesma ação de movimentação entre classes e ainda escolher se quer apagar um número específica de versões desatualizadas do objeto;
- **Marcadores de exclusão de objeto expirado**: definir um prazo de validade em dias de vida para o objeto para, ao atingir a validade, ser deletado;
- **Carregamentos Multipart incompletos**: quando um objeto é carregado no S3 usando a API de `multipart upload`, é possível excluir as partes corrompidas de cargas incompletas usando esse recurso.

**Exemplo de uma lifecyle policy**
![lifecycle](../imagens/s3-lifecycle.png "Exemplo de um S3 Lifecycle rule")

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-lifecycle-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html)

### 3.2. Bloqueio de objetos

Você pode habilitar esse recurso ao criar um bucket para prevenir deleções acidentais ou que o objeto seja sobrescrito.

> **Warning**
> - Você só consegue habilitar esse recurso na criação do bucket (não é possível habilitar depois);
> - Para poder habilitar esse recurso, o versionamento do bucket precisa estar habilitado.

![block](../imagens/s3-block.png "Bloqueio de objetos")

Você também pode exigir uma confirmação com MFA para executar a deleção ou atualização de um objeto protegido.

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-object_lock-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lock.html)

### 3.3. Replicação

É possível configurar o bucket para fazer replicação de dados em um outro bucket, de modo que ao inserir objetos no bucket source, o dado é automaticamente replicado no bucket target.

> **Note**
> - Os buckets podem estar em Regions diferentes.

> **Warning**
> - Você consegue habilitar a replicação em um bucket existente, porém, os dados inseridos antes da habilitação da replicação não são copiados para o bucket replicado.

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-replication-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication.html)

### 3.4. S3 Batch Operations

Recurso que permite realizar diversas operações em larga escala nos objetos do S3. Você pode utilizar para:

- Copiar objetos
- Restaurar diversos objetos do Glacier

**Terminologia**

- **Job**: unidade de trabalho do S3 Batch Operations. Contém todas as informações necessários para realizar as operações em objetos listados em um arquivo de manifesto (json);
- **Operation**: é o tipo de API action que você quer executar na operação batch. Cada job opera um único tipo de operação através dos objetos especificados no manifesto (GET, COPY);
- **Task**: unidade de execução de um job. Representa uma única chamada de uma operation em um objeto. O S3 Batch Operations cria uma task para cada objeto especificado no manifesto.

**Exemplo 1**: Usar o S3 Batch Operations para restaurar diversos objetos do Glacier Deep Archive.

> **Cenário**: possuo um bucket chamado `gus-bucket-pessoal` na região `us-east-2` que possui uma pasta chamada `livros`. Essa pasta possui subpastas de categorias de livros como `computação`, `matematica` e `fisica` e dentro de cada uma delas há diversos PDFs armazenados no Glacier Deep Archive.

![Batch Operantions](../imagens/s3-batch-ops.png "AWS S3 Batch Operations")

Acessar o menu "Operações em lote" como destacado na imagem anterior. Alterar a região do job para a mesma região do bucket (no meu caso, us-east-2) e criar o job.

![Batch Operantions](../imagens/s3-batch-create-job.png "AWS S3 Batch Operations")

Para informar ao job quais objetos sofrerão a operação em lote, é preciso informar um arquivo de manifesto.

![](../imagens/s3-batch-manifest.png "Batch Operations Manifest")

O manifesto pode ser:

- Um arquivo `manifest.json` gerado pelo [Relatório de Inventário do S3](https://docs.aws.amazon.com/pt_br/AmazonS3/latest/userguide/storage-inventory.html?icmpid=docs_amazons3_console);

- Pode ser um arquivo csv configurado por você, como no exemplo a seguir:

Sem Version ID
```json
Examplebucket,objectkey1
Examplebucket,objectkey2
Examplebucket,objectkey3
Examplebucket,photos/jpgs/objectkey4
Examplebucket,photos/jpgs/newjersey/objectkey5
Examplebucket,object%20key%20with%20spaces
```

Com Version ID (opcional)
```json
Examplebucket,objectkey1,PZ9ibn9D5lP6p298B7S9_ceqx1n5EJ0p
Examplebucket,objectkey2,YY_ouuAJByNW1LRBfFMfxMge7XQWxMBF
Examplebucket,objectkey3,jbo9_jhdPEyB4RrmOxWS0kU0EoNrU_oI
Examplebucket,photos/jpgs/objectkey4,6EqlikJJxLTsHsnbZbSRffn24_eh5Ny4
Examplebucket,photos/jpgs/newjersey/objectkey5,imHf3FAiRsvBW_EHB8GOu.NHunHO1gVs
Examplebucket,object%20key%20with%20spaces,9HkPvDaZY5MVbMhn6TMn1YTb5ArQAo3w
```

Apenas o `Bucket` e o `Object ID` são obrigatórios.

Como no meu caso tenho mais de 300 objetos no Glacier Deep Archive, vou usar o Relatório de Inventário do S3 para gerar um csv com todos esses objetos pra mim.

O Amazon S3 Inventory fornece arquivos de saída nos formatos CSV (valores separados por vírgulas), ORC (colunar de linhas otimizado do Apache) ou Apache Parquet que listam seus objetos e os metadados correspondentes, diária ou semanalmente, para um bucket do S3 ou prefixo compartilhado (ou seja, objetos que tenham nomes que comecem com uma string comum).

Acessar as configurações de gerenciamento do bucket.

![](../imagens/s3-inventory-management.png)

Criar uma configuração de inventário.

![](../imagens/s3-inventory-create.png)

Informe um nome e o prefixo do escopo do relatório de inventário, que serão os objetos que estarão listados no relatório. No meu caso, todos os objetos estão na pasta `livros`.

![](../imagens/s3-inventory-name.png)

Configure um bucket target onde o manifest.json será salvo. O bucket target precisa estar na mesma região do bucket origem.

![](../imagens/s3-inventory-target.png)

Escolha a frequência e formato do relatório.

![](../imagens/s3-inventory-format.png)

> **Note**
> - O primeiro relatório só é gerado após 48h.

Caso queira, você pode adicionar informações ao relatório.

![](../imagens/s3-inventory-list.png)

Aguardar cerca de 48h até que seu relatório de inventário esteja disponível no bucket de destino.

![](../imagens/s3-inventory-ok.png)

Assim que o relatório estiver disponível, selecioner o relatório e clicar em `Criar trabalho a partir do manifesto`

![](../imagens/s3-inventory-criar-trabalho.png)

As informações do job batch serão preenchidas automaticamente com base no manifesto do relatório.

Selecionar a opração em lote que deseja realizar, no meu caso, será restauração de objetos do Glacier Deep Archive.

![](../imagens/s3-batch-restore.png)

Escolher as configurações específicas da operação que vai realizar e clicar em `Próximo`.

![](../imagens/s3-batch-restore2.png)

Fazer as configurações adicionais do job escolhendo `prioridade de execução`, `Bucket de destino do relatório de execução do job` e `IAM Role` a ser usada no processamento.

Nessa etapa, é precisa criar uma IAM Role que permita a execução do S3 Batch Operations. Fiz a criação da seguinte role adicionando a policy de `S3FullAccess`.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "batchoperations.s3.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

Assim que o job estiver pronto, fazer a execução.

![](../imagens/s3-batch-execute.png)

Aguardar a execução do job e checar se a operação teve sucesso. No meu caso, houve falha em 9% dos objetos.

![](../imagens/s3-batch-results.png)

Para checar o que ocorreu, acessar o bucket de destino do report de execução.

![](../imagens/s3-batch-results2.png)

Dentro da pasta `/results`, vai existir um arquivo csv com os objetos cuja operação em lote teve sucesso e outro com os objetos que a operação falhou.

![](../imagens/s3-batch-results3.png)

Lista dos 17 objetos em que houve falha no job do S3 Batch Operations.

![](../imagens/s3-batch-errors.png)

O motivo do erro, é que os 17 objetos não estavam armazenados no Glacier Deep Archive, sendo impossível de fazer o restor, como no caso do objeto `livros/eletrica/CircFoto-sistemas-opticos.pdf` que estava armazenado no Intelligent-Tiering.

![](../imagens/s3-batch-errors2.png)

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-batch_operations-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/batch-ops.html)

### 3.5. Versionamento

O versionamento te permite manter diversas variantes de um objeto no mesmo bucket. Você pode usá-la para se proteger contra operações não intencionais do usuário e de falhas da aplicação, inclusive contra deleção ou substituição não intencional.

Ao excluir um objeto de um bucket com versionamento habilitado, o S3 irá inserir um **marcador de exclusão** em vez de remover o objeto permanentemente. O marcador de exclusão se torna a versão atual do objeto.

> Depois que um bucket é habilitado para versionamento, ele nunca pode voltar a um estado sem versionamento novamente, mas você pode **suspender o versionamento** nesse bucket.

O estado de versionamento se aplica a TODOS os objetos do bucket e não somente a alguns.

Se você já tiver objetos no bucket quando o versionamento for habilitado, os objetos existentes permanecerão com `OBJECT_ID` nulo, e só receberão um ID quando sofrerem alguma alteração.

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-Versionamento-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/pt_br/AmazonS3/latest/userguide/Versioning.html)

---

## 4. Gerenciamento de acesso e segurança

### 4.1. Bloqueio de acesso público

Por padrão, os buckets de S3 e seus objetos são privados. O bloqueio de acesso público do S3 fornece quatro configurações. É possível aplicar essas configurações em qualquer combinação a pontos de acesso individuais, buckets ou contas da AWS inteiras.

- Se você aplicar uma configuração a uma conta, ela se aplica a todos os buckets e pontos de acesso de propriedade dessa conta;
- Se você aplicar uma configuração a um bucket, ela se aplicará a todos os pontos de acesso associados a esse bucket.

> **Warning**
> - O Amazon S3 não oferece suporte a configurações de bloqueio de acesso público por objeto.

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-Block_Public_Access-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/pt_br/AmazonS3/latest/userguide/access-control-block-public-access.html)

### 4.2. IAM

Com o IAM, é possível gerenciar, de maneira centralizada, permissões que controlam quais recursos da AWS os usuários poderão acessar.

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-IAM_for_S3-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/pt_br/AmazonS3/latest/userguide/s3-access-control.html)

### 4.3. Bucket Policy


### 4.4. Endpoints


### 4.5. ACLs


### 4.6. Propriedade de objeto do S3


### 4.7. IAM Access Analyzer para S3

---

## 5. Outros recursos

### 5.1. S3 Storage Lens

### 5.2. Análise de Classes de Armazenamento

### 5.3. S3 Transfer Accelerator

### 5.4. Logs de Acesso

### 5.5. S3 Select

### 5.6. Hospedagem de Sites Estáticos

---

## 6. Modelo de consistência de Dados
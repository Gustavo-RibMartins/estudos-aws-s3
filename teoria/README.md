# ![S3](../imagens/S3.png "Ícone do AWS S3") Estudos de AWS S3 - Teoria

> **Simple Storage Service (S3)**: sistema de armazenamento de objetos

- [1. Conceitos iniciais](#1-conceitos-iniciais)
- [2. Classes de Armazenamento](#2-classes-de-armazenamento)
- [3. Gerenciamento de Armazenamento](#3-gerenciamento-de-armazenamento)

    - [3.1. Política de Ciclo de Vida](#31-política-de-ciclo-de-vida)
    - [3.2. Bloqueio de Objetos](#32-bloqueio-de-objetos)
    - [3.3. Cross-Replication](#33-replicação)
    - [3.4. S3 Batch Operations](#34-s3-batch-operations)

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

[![Home](https://img.shields.io/badge/voltar_ao_sumario-0A66C2?style=for-the-badge&logo=&logoColor=white)](#s3-estudos-de-aws-s3---teoria) [![Refs3](https://img.shields.io/badge/Referencia-batch_operations-0A66C2?style=for-the-badge&logo=&logoColor=white)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/batch-ops.html)

---


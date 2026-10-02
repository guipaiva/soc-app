# Central de Incidentes

Projeto de semestre da disciplina Programação para Web e Dispositivos Móveis (Cibersegurança).
Um painel de controle de incidentes de segurança, no estilo de um SOC: cada incidente tem
título, tipo, severidade, status e um responsável, e a equipe acompanha tudo por aqui.

## Rodando

```bash
flutter pub get
flutter run -d chrome
```

## Como trabalhar no projeto

Cada aluno trabalha no próprio fork; a entrega de cada atividade é um Pull Request do fork para
o `main` deste repositório.

### Uma vez, ao começar

No GitHub, clique em **Fork** neste repositório. Depois:

```bash
git clone https://github.com/<seu-usuario>/soc-app.git
cd soc-app
flutter pub get
flutter run -d chrome
```

### Toda atividade

No GitHub, no seu fork, clique em **Sync fork** para trazer o `main` atualizado. Depois:

```bash
git checkout main
git pull
git checkout -b aula-07              # número da aula
# ... trabalho, commits ...
git push -u origin aula-07
```

Depois, no GitHub, abra um Pull Request do seu branch para o `main` de `guipaiva/soc-app` e cole
o link no Canvas.

O PR não é mergeado. Na semana seguinte, o `main` já traz a versão de referência daquela atividade.

O PR precisa compilar (`flutter analyze` sem erros) e a tela precisa abrir com `flutter run -d chrome`.

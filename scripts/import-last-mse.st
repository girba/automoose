suffix := '.mse'.
mseFiles := FileDirectory default fileNames select: [:each | each endsWith: suffix].
wantedMse := mseFiles asSortedCollection last.
model := MooseModel new importFromMSEStream: 
  (StandardFileStream readOnlyFileNamed: wantedMse).
model name: (FileDirectory baseNameFor: wantedMse).
MooseModel root add: model.
MooseModel root allModels first inferNamespaceParentsBasedOnNames.
MooseModel root allModels first ensureClassesAndNamespaces.
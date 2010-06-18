mooseSuitePackages := Set new.
((ConfigurationOfMoose new project version: 'default') packages)
	do: [ :spec | mooseSuitePackages add: spec name ].
(ConfigurationOfMoose new project version: 'default') projects do: [:each |
	(each version packages) do: [:spec | mooseSuitePackages add: spec name ]].
mooseModel := MooseModel new.
mooseImporter := MooseSqueakClassPackageImporterTask new.
mooseImporter importingContext mergeClassAndMetaclass. 
mooseImporter
	candidateClass: CandidateListOperator;
	importerClass: SmalltalkImporter;
	model: mooseModel; 
	addFromPackagesNamed: mooseSuitePackages;
	run.
MooseModel root add: mooseModel
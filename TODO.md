# TODO list

+ Operazioni su una lista di input (invece di innestare delle add per esempio)
- vericare definizione di scalari, vettori e matrici (tensori) in TensorFlow
- introduzione degli array multidimensionali e relative operazioni
- versione con operazioni su matrici: matrice di pesi (ingressi X uscite)
- versione con batch di input
- gestione delle distribuzioni di pesi in inizializzazione
- override degli operatori più comuni

- Introdurre Operation e Tensor (Output)
- Ottimizatore con aggiornamento delle variabili con gradiente calcolato dalla backprop
- Rivedere nomi: checkParentDependency, checkInternalDependency, checkCompositeDependency
- Rivedere i nomi: propagateLocalGradients, propagateTargetGradients, evaluateLocalGradients, evaluateTargetGradients
- Metodo evaluateTargetGradients automatico

- relazione tra nodi (che tipi di relazione esistono? pensa anche al variableupdate...)
- metodi per navigare il descrittore
- testare anche lo strong mode
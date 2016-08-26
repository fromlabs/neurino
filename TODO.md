# TODO list

+ Capire come funzionano le operazioni di assegnamento delle variabili
+ Implementare un batch di operazioni
+ Calcolo della loss
+ Implementare un nodo composto (vedi loss per esempio)
+ Implementare un nodo che permetta di memorizzare valori delle esecuzioni precedenti (i - 1, i - 2, ...)

+ costruzione model descriptor
+ identificazione nodi
+ check univocità identificativi (il descrittore deve controllare tutti i nodi creati)

- stato del descrittore come raccolta di tutti gli stati dei nodi del descrittore
- stato di un nodo: ogni nodo definisce il proprio stato e le modalità di ereditarietà da quello precedente
- sessione come coppia descrittore, stato
- evaluation

- variable update
- relazione tra nodi (che tipi di relazione esistono? pensa anche al variableupdate...)

- Calcolo del gradiente con backprop
- Aggiornamento delle variabili con gradiente calcolato dalla backprop
- Distinzione tra azioni e valutazioni

- metodi per navigare il descrittore
- testare anche lo strong mode

- Evitare utilizzo delle costanti magari con wrapper automatici
- Matrici n-dimensionali come valori
- Override degli operatori più comuni
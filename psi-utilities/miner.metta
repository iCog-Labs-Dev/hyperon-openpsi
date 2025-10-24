!(import! &self python_utils)

(: addPerceptions (-> hyperon::space::DynSpace Expression (->)))
(= (addPerceptions $space $perceptions)
    (if (== $perceptions ())
        ()
        (add-reduct $space (superpose $perceptions))
    )
)

(: miner (-> hyperon::space::DynSpace Number Expression))
(= (miner $perceptaSpace $noOfRules)
    (let* (
          ($perceptaList (collapse (get-atoms $perceptaSpace)))
          ($perceptaCount (size-atom $perceptaList))
          ($preprocessedResult (pyModuleX query_llm  ($perceptaList $noOfRules $perceptaCount)))
    )
      $preprocessedResult
))
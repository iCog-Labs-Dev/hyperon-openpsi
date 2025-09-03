!(register-module! ../../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v1)

!(bind! &testSpace (new-space))
!(bind! &RuleSpace (new-space))

(= (addRulesToTestSpace $space)
    (add-reduct $space (superpose     
        
    (
            
        ((: r1 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.9 0.6) explore)) 
          (Goal found_target 1.0 1.0)))) 2)

;; r2: Approach after finding target
((: r2 ((TTV 1 (STV 0.75 0.65)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal found_target 1.0 1.0) approach)) 
          (Goal near_target 1.0 1.0)))) 3)

;; r3: Interact when near
((: r3 ((TTV 1 (STV 0.7 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal near_target 1.0 1.0) interact)) 
          (Goal task_done 1.0 1.0)))) 2)

;; r4: Report task done
((: r4 ((TTV 1 (STV 0.65 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal task_done 1.0 1.0) report)) 
          (Goal mission_complete 1.0 1.0)))) 10)

;; r5: Do nothing and become low energy
((: r5 ((TTV 1 (STV 0.5 0.5)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.8 0.5) idle)) 
          (Goal low_energy 1.0 1.0)))) 1)

;; r6: Analyze after mission complete
((: r6 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
          (AND_LINK ((Goal mission_complete 0.9 0.7) analyze)) 
          (Goal analyze_data 1.0 1.0)))) 4)

;; r7: Upload results after analysis
((: r7 ((TTV 1 (STV 0.7 0.7)) 
            (IMPLICATION_LINK 
          (AND_LINK ((Goal analyze_data 0.85 0.7) upload)) 
          (Goal upload_results 1.0 1.0)))) 2)

;; r8: Reboot after upload
((: r8 ((TTV 1 (STV 0.9 0.8)) 
            (IMPLICATION_LINK 
          (AND_LINK ((Goal upload_results 0.95 0.75) reboot)) 
          (Goal reset_system 1.0 1.0)))) 1)

    )
        )
    )

)
(= (addRules $space) 
    (add-reduct $space (superpose (
    ;; r1: Explore when initialized
    ((: r1 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.9 0.6) explore)) 
            (Goal found_target 1.0 1.0)))) 2)

    ;; r2: Approach after finding target
    ((: r2 ((TTV 1 (STV 0.75 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal found_target 1.0 1.0) approach)) 
            (Goal near_target 1.0 1.0)))) 3)

    ;; r3: Interact when near target
    ((: r3 ((TTV 1 (STV 0.7 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal near_target 1.0 1.0) interact)) 
            (Goal task_done 1.0 1.0)))) 2)

    ;; r4: Report task done
    ((: r4 ((TTV 1 (STV 0.65 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal task_done 1.0 1.0) report)) 
            (Goal mission_complete 1.0 1.0)))) 10)

    ;; r5: Idle leads to low energy
    ((: r5 ((TTV 1 (STV 0.5 0.5)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal init 0.8 0.5) idle)) 
            (Goal low_energy 1.0 1.0)))) 1)

    ;; r6: Recharge when low energy
    ((: r6 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal low_energy 1.0 1.0) recharge)) 
            (Goal full_energy 1.0 1.0)))) 3)

    ;; r7: Analyze after mission complete
    ((: r7 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal mission_complete 0.9 0.7) analyze)) 
            (Goal analyze_data 1.0 1.0)))) 4)

    ;; r8: Upload results after analysis
    ((: r8 ((TTV 1 (STV 0.7 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal analyze_data 0.85 0.7) upload)) 
            (Goal upload_results 1.0 1.0)))) 2)

    ;; r9: Reboot after upload
    ((: r9 ((TTV 1 (STV 0.9 0.8)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal upload_results 0.95 0.75) reboot)) 
            (Goal reset_system 1.0 1.0)))) 1)

    ;; r10: Run diagnostics after reboot
    ((: r10 ((TTV 1 (STV 0.85 0.8)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal reset_system 0.9 0.7) diagnose)) 
            (Goal system_checked 1.0 1.0)))) 5)

    ;; r11: Update firmware when checked
    ((: r11 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal system_checked 0.85 0.7) update)) 
            (Goal firmware_updated 1.0 1.0)))) 2)

    ;; r12: Calibrate sensors after update
    ((: r12 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal firmware_updated 0.9 0.75) calibrate)) 
            (Goal sensors_calibrated 1.0 1.0)))) 3)

    ;; r13: Map environment after calibration
    ((: r13 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal sensors_calibrated 0.9 0.75) map)) 
            (Goal map_ready 1.0 1.0)))) 4)

    ;; r14: Detect obstacle while mapping
    ((: r14 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal map_ready 0.85 0.7) detect_obstacle)) 
            (Goal obstacle_detected 1.0 1.0)))) 2)

    ;; r15: Avoid obstacle
    ((: r15 ((TTV 1 (STV 0.8 0.75)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal obstacle_detected 0.9 0.75) avoid)) 
            (Goal path_clear 1.0 1.0)))) 3)

    ;; r16: Resume mapping after obstacle
    ((: r16 ((TTV 1 (STV 0.65 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal path_clear 0.95 0.8) map)) 
            (Goal map_complete 1.0 1.0)))) 2)

    ;; r17: Store map after completion
    ((: r17 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal map_complete 0.9 0.75) store)) 
            (Goal map_stored 1.0 1.0)))) 3)

    ;; r18: Share map with peers
    ((: r18 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal map_stored 0.85 0.7) share)) 
            (Goal map_shared 1.0 1.0)))) 2)

    ;; r19: Request feedback after sharing
    ((: r19 ((TTV 1 (STV 0.8 0.75)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal map_shared 0.9 0.8) request_feedback)) 
            (Goal feedback_received 1.0 1.0)))) 4)

    ;; r20: Adjust plan with feedback
    ((: r20 ((TTV 1 (STV 0.85 0.8)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal feedback_received 0.95 0.85) adjust_plan)) 
            (Goal plan_adjusted 1.0 1.0)))) 3)

    ;; r21: Continue mission with adjusted plan
    ((: r21 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal plan_adjusted 0.9 0.75) continue)) 
            (Goal mission_active 1.0 1.0)))) 4)

    ;; r22: Monitor environment
    ((: r22 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal mission_active 0.85 0.7) monitor)) 
            (Goal environment_monitored 1.0 1.0)))) 2)

    ;; r23: Detect anomaly
    ((: r23 ((TTV 1 (STV 0.8 0.75)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal environment_monitored 0.9 0.75) detect_anomaly)) 
            (Goal anomaly_detected 1.0 1.0)))) 3)

    ;; r24: Respond to anomaly
    ((: r24 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal anomaly_detected 0.85 0.7) respond)) 
            (Goal anomaly_resolved 1.0 1.0)))) 5)

    ;; r25: Log anomaly
    ((: r25 ((TTV 1 (STV 0.65 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal anomaly_resolved 0.9 0.75) log)) 
            (Goal anomaly_logged 1.0 1.0)))) 2)

    ;; r26: Secure system
    ((: r26 ((TTV 1 (STV 0.8 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal anomaly_logged 0.95 0.8) secure)) 
            (Goal system_secured 1.0 1.0)))) 3)

    ;; r27: Resume mission after security
    ((: r27 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal system_secured 0.9 0.75) continue)) 
            (Goal mission_active 1.0 1.0)))) 4)

    ;; r28: Check battery
    ((: r28 ((TTV 1 (STV 0.6 0.55)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal mission_active 0.85 0.7) check_battery)) 
            (Goal battery_status 1.0 1.0)))) 2)

    ;; r29: Alert when battery low
    ((: r29 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal battery_status 0.9 0.75) alert)) 
            (Goal battery_alert 1.0 1.0)))) 1)

    ;; r30: Return to base on alert
    ((: r30 ((TTV 1 (STV 0.8 0.75)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal battery_alert 0.95 0.8) return)) 
            (Goal base_reached 1.0 1.0)))) 5)

    ;; r31: Dock when base reached
    ((: r31 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal base_reached 0.9 0.75) dock)) 
            (Goal docked 1.0 1.0)))) 2)

    ;; r32: Charge when docked
    ((: r32 ((TTV 1 (STV 0.85 0.8)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal docked 0.95 0.85) charge)) 
            (Goal full_energy 1.0 1.0)))) 3)

    ;; r33: Shutdown after charge
    ((: r33 ((TTV 1 (STV 0.65 0.6)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal full_energy 0.9 0.75) shutdown)) 
            (Goal system_off 1.0 1.0)))) 1)

    ;; r34: Wake when system off
    ((: r34 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal system_off 0.85 0.7) wake)) 
            (Goal system_on 1.0 1.0)))) 3)

    ;; r35: Initialize sensors
    ((: r35 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal system_on 0.9 0.75) init_sensors)) 
            (Goal sensors_ready 1.0 1.0)))) 2)

    ;; r36: Train model after sensors ready
    ((: r36 ((TTV 1 (STV 0.85 0.8)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal sensors_ready 0.95 0.85) train)) 
            (Goal model_trained 1.0 1.0)))) 4)

    ;; r37: Predict after training
    ((: r37 ((TTV 1 (STV 0.7 0.65)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal model_trained 0.9 0.75) predict)) 
            (Goal prediction_ready 1.0 1.0)))) 3)

    ;; r38: Validate after prediction
    ((: r38 ((TTV 1 (STV 0.75 0.7)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal prediction_ready 0.85 0.7) validate)) 
            (Goal validation_done 1.0 1.0)))) 2)

    ;; r39: Save model after validation
    ((: r39 ((TTV 1 (STV 0.8 0.75)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal validation_done 0.95 0.8) save)) 
            (Goal model_saved 1.0 1.0)))) 3)

    ;; r40: Deploy after saving model
    ((: r40 ((TTV 1 (STV 0.9 0.85)) 
            (IMPLICATION_LINK 
            (AND_LINK ((Goal model_saved 0.9 0.75) deploy)) 
            (Goal model_deployed 1.0 1.0)))) 5)
))))


!(addRulesToTestSpace &RuleSpace)
!(addRules &testSpace)

!(assertEqual (getWeightFromRule ((: r1 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 2)) 2)
!(assertEqual (getWeightFromRule ((: r2 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 3)) 3)
!(assertEqual (selectSingleAction &RuleSpace (()) 1.0) (() ()))
!(assertEqual (selectActionFromRule ((: r1 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 2)) explore)

!(assertEqual (selectSingleAction &RuleSpace (collapse (get-atoms &RuleSpace)) 10) (((: r4 ((TTV 1 (STV 0.65 0.6)) (IMPLICATION_LINK (AND_LINK ((Goal task_done 1 1) report)) (Goal mission_complete 1 1)))) 10) report))
!(assertEqual (findRulesWithGoalAsContext &RuleSpace low_energy) ())
!(assertEqual (findRulesWithGoalAsContext &RuleSpace found_target) (((: r2 ((TTV 1 (STV 0.75 0.65)) (IMPLICATION_LINK (AND_LINK ((Goal found_target 1 1) approach)) (Goal near_target 1 1)))) 3)))
!(assertEqual (planner &RuleSpace init  mission_complete) (explore approach interact report))

!(assertEqual (planner &testSpace init model_deployed) (explore recharge shutdown wake init_sensors train predict validate save deploy))

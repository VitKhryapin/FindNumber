//
//  GameViewController.swift
//  FindNumber
//
//  Created by Vitaly Khryapin on 26.02.2022.
//

import UIKit

class GameViewController: UIViewController {
    
    // MARK: - PROPERTIES
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var nextDigit: UILabel!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    lazy var game = Game(countItems: buttons.count) { [weak self] (status, time) in
        guard let self = self else {return}
        self.timerLabel.text = time.secondsToString()
        self.updateInfoGame(with: status)
    }
    
    // MARK: - LIFE CYCLE
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        game.stopGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    @IBAction func pressButton(_ sender: UIButton) {
        guard let buttonIndex = buttons.firstIndex(of: sender) else {return}
        game.check(index: buttonIndex)
        updateUI()
    }
    @IBAction func newGamePress(_ sender: UIButton) {
        game.newGame()
        sender.isHidden = true
        setupScreen()
    }
    
    private func setupScreen() {
        for index in game.items.indices {
            buttons[index].setTitle(game.items[index].title, for: .normal)
            buttons[index].alpha = 1
            buttons[index].isEnabled = true
        }
        nextDigit.text = game.nexItem?.title
        if !Settings.shared.currentSettings.timerState {
            timerLabel.isHidden = true
        }
    }
    
    private func updateUI (){
        for index in game.items.indices {
            buttons[index].alpha = game.items[index].isFound ? 0 : 1
            buttons[index].isEnabled = !game.items[index].isFound
            if game.items[index].isError{
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.buttons[index].backgroundColor = .systemRed
                } completion: { [weak self] (_) in
                    self?.buttons[index].backgroundColor = .white
                    self?.game.items[index].isError = false
                }
            }
        }
        nextDigit.text = game.nexItem?.title
        updateInfoGame(with: game.status)
    }
    
    private func updateInfoGame(with status:StatusGame) {
        switch status {
        case .start:
            statusLabel.text = "Игра началась"
            statusLabel.textColor = .systemBlue
            newGameButton.isHidden = true
        case .win:
            statusLabel.text = "Вы выиграли!"
            statusLabel.textColor = .green
            newGameButton.isHidden = false
            if game.isNewRecord {
                showAlert()
            }else{
                showAlertAcionSheet()
            }
        case .lose:
            statusLabel.text = "Вы проиграли!"
            statusLabel.textColor = .red
            newGameButton.isHidden = false
            showAlertAcionSheet()
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Поздравляем!", message: "Вы установили новый рекорд!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showAlertAcionSheet() {
        let alert = UIAlertController(title: "Что вы хотите сделать далее?", message: nil, preferredStyle: .actionSheet)
        let newGameAction = UIAlertAction(title: "Начать новую игру", style: .default) { [weak self] _ in
            self?.game.newGame()
            self?.setupScreen()
        }
        let showRecord = UIAlertAction(title: "Посмотреть рекорд", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: "recordVC", sender: nil)
        }
        let menuAction = UIAlertAction(title: "Перейти в меню", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(newGameAction)
        alert.addAction(showRecord)
        alert.addAction(menuAction)
        alert.addAction(cancelAction)
        if let popover = alert.popoverPresentationController{
            popover.sourceView = self.view
            popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = UIPopoverArrowDirection.init(rawValue: 0)
        }
        present(alert, animated: true, completion: nil)
    }
}

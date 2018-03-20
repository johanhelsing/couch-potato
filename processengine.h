#ifndef PROCESSENGINE_H
#define PROCESSENGINE_H

#include <QObject>
#include <QVector>
#include <QProcess>

class Process : public QProcess {
    Q_OBJECT
    Q_PROPERTY(QString standardError READ standardError NOTIFY standardErrorChanged)

public:
    QString standardError() const { return m_stderr; }
    Process(QObject *parent = nullptr) : QProcess(parent) {
        connect(this, &QProcess::readyReadStandardError, [&](){
            m_stderr+=readAllStandardError();
            standardErrorChanged();
        });
    }

signals:
    void standardErrorChanged();

private:
    QString m_stderr;
};

class ProcessEngine : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString waylandDisplay READ waylandDisplay WRITE setWaylandDisplay NOTIFY waylandDisplayChanged)

public:
    ProcessEngine(QObject *parent = nullptr);

    QString waylandDisplay() const { return m_waylandDisplay; }
    void setWaylandDisplay(const QString &display);

    Q_INVOKABLE Process *run(const QString &command, const QString &workingDirectory = "");
    Q_INVOKABLE void killall();

signals:
    void waylandDisplayChanged();

private:
    QVector<QProcess *> m_processes;
    QString m_waylandDisplay;
};

#endif // PROCESSENGINE_H
